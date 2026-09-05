// Local storage: SQLite on mobile/desktop, in-memory on web.
// Catalog (categories/poems) comes from the Nest API.

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/poem.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  static const String _dbVersion = '1.0.0';

  /// In-memory favorites for web (sqflite is unsupported in Chrome).
  final Map<String, Poem> _webFavorites = {};

  /// Call once at startup — always completes, including on web.
  Future<void> init() async {
    if (kIsWeb) return;
    await database;
  }

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not available on web');
    }
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'poems.db');
    return openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
        CREATE TABLE poems(
          id TEXT PRIMARY KEY,
          title TEXT,
          content TEXT,
          category TEXT,
          category_id TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    await db.execute('''
        CREATE TABLE favorites(
          category TEXT PRIMARY KEY
        )
      ''');
    await db.execute('''
        CREATE TABLE poem_favorites(
          poem_id TEXT PRIMARY KEY,
          title TEXT,
          content TEXT,
          category TEXT,
          category_id TEXT,
          added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    await db.execute('''
        CREATE TABLE metadata(
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    await db.insert('metadata', {'key': 'db_version', 'value': _dbVersion});
  }

  Future _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
          CREATE TABLE favorites(
            category TEXT PRIMARY KEY
          )
        ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
          CREATE TABLE poem_favorites(
            poem_id INTEGER PRIMARY KEY,
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      await db.execute('''
          CREATE TABLE metadata(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      await db.insert('metadata', {'key': 'db_version', 'value': _dbVersion});
    }
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS poem_favorites');
      await db.execute('''
          CREATE TABLE poem_favorites(
            poem_id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            category TEXT,
            category_id TEXT,
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      try {
        await db.execute('ALTER TABLE poems ADD COLUMN category_id TEXT');
      } catch (_) {}
    }
  }

  Future<bool> doesPoemExist(String title) async {
    if (kIsWeb) return false;
    final db = await database;
    final result = await db.query(
      'poems',
      where: 'title = ?',
      whereArgs: [title],
    );
    return result.isNotEmpty;
  }

  Future<void> insertPoem(Poem poem) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'poems',
      {
        if (poem.id != null) 'id': poem.id,
        'title': poem.title,
        'content': poem.content,
        'category': poem.category,
        'category_id': poem.categoryId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updatePoem(Poem poem) async {
    if (kIsWeb) return 0;
    final db = await database;
    final map = poem.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(
      'poems',
      map,
      where: 'id = ?',
      whereArgs: [poem.id],
    );
  }

  Future<void> deletePoem(String id) async {
    if (kIsWeb) {
      _webFavorites.remove(id);
      return;
    }
    final db = await database;
    await db.delete('poems', where: 'id = ?', whereArgs: [id]);
    await db.delete('poem_favorites', where: 'poem_id = ?', whereArgs: [id]);
  }

  Future<List<Poem>> getPoemsByCategory(String category) async {
    if (kIsWeb) return [];
    final db = await database;
    final maps =
        await db.query('poems', where: 'category = ?', whereArgs: [category]);
    return maps.map(Poem.fromMap).toList();
  }

  Future<List<String>> getCategories() async {
    if (kIsWeb) return [];
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM poems');
    return result.map((row) => row['category'] as String).toList();
  }

  Future<Map<String, int>> getCategoryCounts() async {
    if (kIsWeb) return {};
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM poems GROUP BY category',
    );
    final counts = <String, int>{};
    for (final row in result) {
      counts[row['category'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<int> getTotalPoemCount() async {
    if (kIsWeb) return 0;
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM poems');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> toggleFavorite(String category) async {
    if (kIsWeb) return;
    final db = await database;
    final exists = await db.query(
      'favorites',
      where: 'category = ?',
      whereArgs: [category],
    );
    if (exists.isNotEmpty) {
      await db.delete('favorites', where: 'category = ?', whereArgs: [category]);
    } else {
      await db.insert('favorites', {'category': category});
    }
  }

  Future<bool> isFavorite(String category) async {
    if (kIsWeb) return false;
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getFavoriteCategories() async {
    if (kIsWeb) return [];
    final db = await database;
    final result = await db.query('favorites');
    return result.map((row) => row['category'] as String).toList();
  }

  Future<List<Poem>> getFavoritePoems() async {
    if (kIsWeb) return _webFavorites.values.toList();
    final db = await database;
    final maps = await db.query('poem_favorites', orderBy: 'added_at DESC');
    return maps
        .map(
          (m) => Poem(
            id: m['poem_id'] as String?,
            title: m['title'] as String? ?? '',
            content: m['content'] as String? ?? '',
            category: m['category'] as String? ?? '',
            categoryId: m['category_id'] as String?,
          ),
        )
        .toList();
  }

  Future<void> togglePoemFavorite(Poem poem) async {
    if (poem.id == null) return;
    if (kIsWeb) {
      if (_webFavorites.containsKey(poem.id)) {
        _webFavorites.remove(poem.id);
      } else {
        _webFavorites[poem.id!] = poem;
      }
      return;
    }
    final db = await database;
    final exists = await db.query(
      'poem_favorites',
      where: 'poem_id = ?',
      whereArgs: [poem.id],
    );
    if (exists.isNotEmpty) {
      await db.delete(
        'poem_favorites',
        where: 'poem_id = ?',
        whereArgs: [poem.id],
      );
    } else {
      await db.insert('poem_favorites', {
        'poem_id': poem.id,
        'title': poem.title,
        'content': poem.content,
        'category': poem.category,
        'category_id': poem.categoryId,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<bool> isPoemFavorite(String poemId) async {
    if (kIsWeb) return _webFavorites.containsKey(poemId);
    final db = await database;
    final result = await db.query(
      'poem_favorites',
      where: 'poem_id = ?',
      whereArgs: [poemId],
    );
    return result.isNotEmpty;
  }

  Future<void> clearAllFavorites() async {
    if (kIsWeb) {
      _webFavorites.clear();
      return;
    }
    final db = await database;
    await db.delete('favorites');
    await db.delete('poem_favorites');
  }

  Future<void> clearAllData() async {
    if (kIsWeb) {
      _webFavorites.clear();
      return;
    }
    final db = await database;
    await db.delete('poems');
    await db.delete('favorites');
    await db.delete('poem_favorites');
    await db.delete('metadata');
    await db.insert('metadata', {'key': 'db_version', 'value': _dbVersion});
  }

  Future<List<Poem>> searchPoems(String query) async {
    if (kIsWeb) return [];
    final db = await database;
    final maps = await db.query(
      'poems',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map(Poem.fromMap).toList();
  }

  Future<Map<String, dynamic>> exportPoemsToJson(
      {Function(double)? onProgress}) async {
    try {
      if (kIsWeb) {
        final data = {
          'version': _dbVersion,
          'export_timestamp': DateTime.now().toIso8601String(),
          'poem_favorites': _webFavorites.values
              .map((p) => {
                    'poem_id': p.id,
                    'title': p.title,
                    'content': p.content,
                    'category': p.category,
                  })
              .toList(),
        };
        await Share.share(jsonEncode(data), subject: 'Exported Amharic Poems');
        return {'success': true};
      }

      final db = await database;
      final poems = await db.query('poems');
      final favoriteCategories = await db.query('favorites');
      final poemFavorites = await db.query('poem_favorites');
      final metadata = await db.query('metadata');

      final data = {
        'version': _dbVersion,
        'export_timestamp': DateTime.now().toIso8601String(),
        'poems': poems
            .map((p) => {
                  'id': p['id'],
                  'title': p['title'] ?? '',
                  'content': p['content'] ?? '',
                  'category': p['category'] ?? '',
                  'created_at':
                      p['created_at'] ?? DateTime.now().toIso8601String(),
                  'updated_at':
                      p['updated_at'] ?? DateTime.now().toIso8601String(),
                })
            .toList(),
        'favorites': favoriteCategories
            .map((f) => {'category': f['category'] ?? ''})
            .toList(),
        'poem_favorites': poemFavorites
            .map((pf) => {
                  'poem_id': pf['poem_id'],
                  'added_at':
                      pf['added_at'] ?? DateTime.now().toIso8601String(),
                })
            .toList(),
        'metadata': metadata
            .map((m) => {
                  'key': m['key'] ?? '',
                  'value': m['value'] ?? '',
                })
            .toList(),
      };

      final jsonData = jsonEncode(data);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final filePath = join(tempDir.path, 'poems_export_$timestamp.json');
      final xFile = XFile.fromData(
        utf8.encode(jsonData),
        mimeType: 'application/json',
        name: 'poems_export_$timestamp.json',
      );
      await Share.shareXFiles(
        [xFile],
        text: 'Exported Amharic Poems',
      );

      return {'success': true, 'filePath': filePath};
    } catch (e) {
      return {'success': false, 'error': 'Failed to export poems: $e'};
    }
  }

  Future<Map<String, dynamic>> importPoemsFromJson(
      {Function(double)? onProgress}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return {
          'success': false,
          'error': 'No file selected or picker was cancelled',
        };
      }

      final platformFile = result.files.first;
      if (platformFile.bytes == null) {
        return {
          'success': false,
          'error': 'Failed to read file data from the picked file.',
        };
      }
      final jsonString = utf8.decode(platformFile.bytes!);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data['version'] != _dbVersion) {
        return {
          'success': false,
          'error':
              'Incompatible data version. Expected $_dbVersion, got ${data['version']}',
        };
      }

      if (kIsWeb) {
        final poemFavorites = data['poem_favorites'] as List<dynamic>? ?? [];
        for (final pf in poemFavorites) {
          final id = pf['poem_id']?.toString();
          if (id == null) continue;
          _webFavorites[id] = Poem(
            id: id,
            title: pf['title']?.toString() ?? '',
            content: pf['content']?.toString() ?? '',
            category: pf['category']?.toString() ?? '',
          );
        }
        return {
          'success': true,
          'insertedCount': poemFavorites.length,
          'skippedCount': 0,
        };
      }

      final db = await database;
      var insertedCount = 0;
      var skippedCount = 0;

      await db.transaction((txn) async {
        final poems = data['poems'] as List<dynamic>? ?? [];
        final existingTitles = await txn.query('poems', columns: ['title']);
        final existingTitleSet =
            existingTitles.map((map) => map['title'] as String).toSet();
        final batch = txn.batch();

        for (final poem in poems) {
          if (poem['title'] != null &&
              poem['content'] != null &&
              poem['category'] != null) {
            if (!existingTitleSet.contains(poem['title'].toString())) {
              batch.insert('poems', {
                'id': poem['id']?.toString() ??
                    DateTime.now().microsecondsSinceEpoch.toString(),
                'title': poem['title'].toString(),
                'content': poem['content'].toString(),
                'category': poem['category'].toString(),
                'created_at':
                    poem['created_at'] ?? DateTime.now().toIso8601String(),
                'updated_at':
                    poem['updated_at'] ?? DateTime.now().toIso8601String(),
              });
              insertedCount++;
            } else {
              skippedCount++;
            }
          }
        }

        final favoriteCategories = data['favorites'] as List<dynamic>? ?? [];
        for (final fav in favoriteCategories) {
          if (fav['category'] != null) {
            batch.insert(
              'favorites',
              {'category': fav['category'].toString()},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        final poemFavorites = data['poem_favorites'] as List<dynamic>? ?? [];
        for (final pf in poemFavorites) {
          if (pf['poem_id'] != null) {
            batch.insert(
              'poem_favorites',
              {
                'poem_id': pf['poem_id'].toString(),
                'title': pf['title']?.toString() ?? '',
                'content': pf['content']?.toString() ?? '',
                'category': pf['category']?.toString() ?? '',
                'added_at':
                    pf['added_at'] ?? DateTime.now().toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        final metadata = data['metadata'] as List<dynamic>? ?? [];
        for (final meta in metadata) {
          if (meta['key'] != null && meta['value'] != null) {
            batch.insert(
              'metadata',
              {
                'key': meta['key'].toString(),
                'value': meta['value'].toString(),
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        await batch.commit(noResult: true);
      });

      return {
        'success': true,
        'importedPath': platformFile.path,
        'insertedCount': insertedCount,
        'skippedCount': skippedCount,
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to import poems: $e'};
    }
  }
}
