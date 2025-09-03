// db/db_helper.dart

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// The import for device_info_plus is not used in the provided code,
// but I'll keep it as you had it.
import 'package:device_info_plus/device_info_plus.dart'; 
import '../models/poem.dart';

class DBHelper {
  // Singleton pattern for DBHelper
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  static const String _dbVersion = '1.0.0';

  // Get or initialize the database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  // Initialize the SQLite database
  Future<Database> initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'poems.db');
      print('Initializing database at: $path');
      return await openDatabase(
        path,
        version: 3,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
    } catch (e, stackTrace) {
      print('Database initialization error: $e\nStack trace: $stackTrace');
      rethrow;
    }
  }

  // Create database tables
  Future _createDb(Database db, int version) async {
    try {
      await db.execute('''
          CREATE TABLE poems(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            category TEXT,
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
      print('Database created with version $_dbVersion');
    } catch (e, stackTrace) {
      print('Database creation error: $e\nStack trace: $stackTrace');
      rethrow;
    }
  }

  // Upgrade database schema for new versions
  Future _upgradeDb(Database db, int oldVersion, int newVersion) async {
    try {
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
      print('Database upgraded from version $oldVersion to $newVersion');
    } catch (e, stackTrace) {
      print('Database upgrade error: $e\nStack trace: $stackTrace');
      rethrow;
    }
  }

  // Check if a poem exists by title
  Future<bool> doesPoemExist(String title) async {
    final db = await database;
    final result = await db.query(
      'poems',
      where: 'title = ?',
      whereArgs: [title],
    );
    return result.isNotEmpty;
  }

  // Insert a new poem
  Future<int> insertPoem(Poem poem) async {
    final db = await database;
    return await db.insert('poems', poem.toMap());
  }

  // Update an existing poem
  Future<int> updatePoem(Poem poem) async {
    final db = await database;
    final map = poem.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'poems',
      map,
      where: 'id = ?',
      whereArgs: [poem.id],
    );
  }

  // Delete a poem and its favorite entry
  Future<void> deletePoem(int id) async {
    final db = await database;
    await db.delete('poems', where: 'id = ?', whereArgs: [id]);
    await db.delete('poem_favorites', where: 'poem_id = ?', whereArgs: [id]);
  }

  // Get poems by category
  Future<List<Poem>> getPoemsByCategory(String category) async {
    final db = await database;
    final maps = await db.query('poems', where: 'category = ?', whereArgs: [category]);
    return List.generate(maps.length, (i) => Poem.fromMap(maps[i]));
  }

  // Get all unique categories
  Future<List<String>> getCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM poems');
    return result.map((row) => row['category'] as String).toList();
  }

  // ADDED: Get the number of poems for each category
  Future<Map<String, int>> getCategoryCounts() async {
    final db = await database;
    final result = await db.rawQuery('SELECT category, COUNT(*) as count FROM poems GROUP BY category');
    
    final counts = <String, int>{};
    for (var row in result) {
      final category = row['category'] as String;
      final count = row['count'] as int;
      counts[category] = count;
    }
    return counts;
  }

  // ADDED: Get the total number of all poems
  Future<int> getTotalPoemCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM poems');
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }

  // Toggle favorite status for a category
  Future<void> toggleFavorite(String category) async {
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

  // Check if a category is favorited
  Future<bool> isFavorite(String category) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.isNotEmpty;
  }

  // Get all favorite categories
  Future<List<String>> getFavoriteCategories() async {
    final db = await database;
    final result = await db.query('favorites');
    return result.map((row) => row['category'] as String).toList();
  }

  // Get all favorite poems (from categories and individual favorites)
  Future<List<Poem>> getFavoritePoems() async {
    final db = await database;
    List<Poem> poems = [];
    final favoriteCategories = await getFavoriteCategories();
    if (favoriteCategories.isNotEmpty) {
      final categoryMaps = await db.query(
        'poems',
        where: 'category IN (${List.filled(favoriteCategories.length, '?').join(',')})',
        whereArgs: favoriteCategories,
      );
      poems.addAll(categoryMaps.map((map) => Poem.fromMap(map)));
    }
    final poemFavoriteMaps = await db.query('poem_favorites');
    for (var map in poemFavoriteMaps) {
      final poemId = map['poem_id'] as int;
      final poemMaps = await db.query(
        'poems',
        where: 'id = ?',
        whereArgs: [poemId],
      );
      if (poemMaps.isNotEmpty) {
        poems.add(Poem.fromMap(poemMaps.first));
      }
    }
    final uniquePoems = poems.fold<Map<int, Poem>>({}, (map, poem) {
      if (poem.id != null) map[poem.id!] = poem;
      return map;
    }).values.toList();
    return uniquePoems;
  }

  // Toggle favorite status for a poem
  Future<void> togglePoemFavorite(int poemId) async {
    final db = await database;
    final exists = await db.query(
      'poem_favorites',
      where: 'poem_id = ?',
      whereArgs: [poemId],
    );
    if (exists.isNotEmpty) {
      await db.delete('poem_favorites', where: 'poem_id = ?', whereArgs: [poemId]);
    } else {
      await db.insert('poem_favorites', {
        'poem_id': poemId,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Check if a poem is favorited
  Future<bool> isPoemFavorite(int poemId) async {
    final db = await database;
    final result = await db.query(
      'poem_favorites',
      where: 'poem_id = ?',
      whereArgs: [poemId],
    );
    return result.isNotEmpty;
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    final db = await database;
    await db.delete('favorites');
    await db.delete('poem_favorites');
  }

  // Clear all data and reset metadata
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('poems');
    await db.delete('favorites');
    await db.delete('poem_favorites');
    await db.delete('metadata');
    await db.insert('metadata', {'key': 'db_version', 'value': _dbVersion});
  }

  // Search poems by title or content
  Future<List<Poem>> searchPoems(String query) async {
    final db = await database;
    final maps = await db.query(
      'poems',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Poem.fromMap(maps[i]));
  }

  // ------------------------------------
  // Export/Import Methods (Restructured)
  // ------------------------------------

  // Export poems to a JSON file
  Future<Map<String, dynamic>> exportPoemsToJson({Function(double)? onProgress}) async {
    try {
      final db = await database;
      final poems = await db.query('poems');
      final favoriteCategories = await db.query('favorites');
      final poemFavorites = await db.query('poem_favorites');
      final metadata = await db.query('metadata');

      final data = {
        'version': _dbVersion,
        'export_timestamp': DateTime.now().toIso8601String(),
        'poems': poems.map((p) => {
          'id': p['id'],
          'title': p['title'] ?? '',
          'content': p['content'] ?? '',
          'category': p['category'] ?? '',
          'created_at': p['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at': p['updated_at'] ?? DateTime.now().toIso8601String(),
        }).toList(),
        'favorites': favoriteCategories.map((f) => {'category': f['category'] ?? ''}).toList(),
        'poem_favorites': poemFavorites.map((pf) => {
          'poem_id': pf['poem_id'],
          'added_at': pf['added_at'] ?? DateTime.now().toIso8601String(),
        }).toList(),
        'metadata': metadata.map((m) => {
          'key': m['key'] ?? '',
          'value': m['value'] ?? '',
        }).toList(),
      };

      final jsonData = jsonEncode(data);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final filePath = join(tempDir.path, 'poems_export_$timestamp.json');
      final file = File(filePath);
      await file.writeAsString(jsonData, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exported Amharic Poems',
      );

      return {'success': true, 'filePath': filePath};
    } catch (e, stackTrace) {
      print('Export to JSON error: $e\nStack trace: $stackTrace');
      return {'success': false, 'error': 'Failed to export poems: $e'};
    }
  }

  // ------------------------------------
  // UPDATED IMPORT METHOD
  // ------------------------------------
  // Import poems from a JSON file (Updated for reliability on modern Android)
  Future<Map<String, dynamic>> importPoemsFromJson({Function(double)? onProgress}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      // Check if a file was picked and if it has a valid file property
      if (result == null || result.files.isEmpty) {
        return {'success': false, 'error': 'No file selected or picker was cancelled'};
      }

      // Get the first picked file object
      final platformFile = result.files.first;

      // New, more reliable way to read file content
      // Use platformFile.bytes to get the file data directly
      if (platformFile.bytes == null) {
        return {'success': false, 'error': 'Failed to read file data from the picked file.'};
      }
      final jsonString = utf8.decode(platformFile.bytes!);

      // Now use the jsonString as before
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data['version'] != _dbVersion) {
        return {
          'success': false,
          'error': 'Incompatible data version. Expected $_dbVersion, got ${data['version']}',
        };
      }

      final db = await database;
      int insertedCount = 0;
      int skippedCount = 0;

      await db.transaction((txn) async {
        final poems = data['poems'] as List<dynamic>? ?? [];
        
        final existingTitles = await txn.query('poems', columns: ['title']);
        final existingTitleSet = existingTitles.map((map) => map['title'] as String).toSet();

        final batch = txn.batch();

        for (var poem in poems) {
          if (poem['title'] != null && poem['content'] != null && poem['category'] != null) {
            if (!existingTitleSet.contains(poem['title'].toString())) {
              batch.insert('poems', {
                'title': poem['title'].toString(),
                'content': poem['content'].toString(),
                'category': poem['category'].toString(),
                'created_at': poem['created_at'] ?? DateTime.now().toIso8601String(),
                'updated_at': poem['updated_at'] ?? DateTime.now().toIso8601String(),
              });
              insertedCount++;
            } else {
              skippedCount++;
            }
          }
        }

        final favoriteCategories = data['favorites'] as List<dynamic>? ?? [];
        for (var fav in favoriteCategories) {
          if (fav['category'] != null) {
            batch.insert('favorites', {'category': fav['category'].toString()}, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
        
        final poemFavorites = data['poem_favorites'] as List<dynamic>? ?? [];
        for (var pf in poemFavorites) {
          if (pf['poem_id'] != null) {
            batch.insert('poem_favorites', {
              'poem_id': pf['poem_id'],
              'added_at': pf['added_at'] ?? DateTime.now().toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }

        final metadata = data['metadata'] as List<dynamic>? ?? [];
        for (var meta in metadata) {
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
        // The path might still be a URI, but we don't need it for reading anymore
        'importedPath': platformFile.path, 
        'insertedCount': insertedCount,
        'skippedCount': skippedCount,
      };
    } catch (e, stackTrace) {
      print('Import from JSON error: $e\nStack trace: $stackTrace');
      return {'success': false, 'error': 'Failed to import poems: $e'};
    }
  }
}