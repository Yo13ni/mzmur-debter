import '../db/db_helper.dart';
import '../models/category.dart';
import '../models/poem.dart';
import 'api_service.dart';

/// Offline-first data access for the poem catalog.
///
/// Tries the remote API first and caches every successful response into the
/// local SQLite store. When the network fails it falls back to the cached
/// poems so users can keep reading saved poems with no connection.
class PoemRepository {
  PoemRepository({ApiService? api, DBHelper? db})
      : _api = api ?? ApiService(),
        _db = db ?? DBHelper();

  final ApiService _api;
  final DBHelper _db;

  Future<({List<Category> categories, Map<String, int> counts})>
      getCategoriesWithCounts() async {
    final categories = await getCategories();
    final poems = await getPoems();
    final counts = <String, int>{};
    for (final p in poems) {
      final id = p.categoryId;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return (categories: categories, counts: counts);
  }

  Future<List<Category>> getCategories() async {
    try {
      final categories = await _api.getCategories();
      await _db.cacheCategories(categories);
      return categories;
    } catch (_) {
      final cached = await _db.getCachedCategories();
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  Future<List<Poem>> getPoems({String? categoryId, String? q}) async {
    try {
      final poems = await _api.getPoems(categoryId: categoryId, q: q);
      await _db.cachePoems(poems);
      return poems;
    } catch (_) {
      final total = await _db.getTotalPoemCount();
      if (total == 0) rethrow;
      return _localPoems(categoryId: categoryId, q: q);
    }
  }

  Future<Poem> getPoem(String id) async {
    try {
      final poem = await _api.getPoem(id);
      await _db.insertPoem(poem);
      return poem;
    } catch (_) {
      final local =
          await _db.getCachedPoems().then((poems) => poems.where((p) => p.id == id).toList());
      if (local.isEmpty) rethrow;
      return local.first;
    }
  }

  Future<List<Poem>> searchPoems(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final results = await _api.getPoems(q: query.trim());
      await _db.cachePoems(results);
      return results;
    } catch (_) {
      return _localPoems(q: query.trim());
    }
  }

  Future<Map<String, dynamic>> createSubmission({
    required String title,
    required String content,
    required String categoryId,
    String? submitterName,
  }) {
    return _api.createSubmission(
      title: title,
      content: content,
      categoryId: categoryId,
      submitterName: submitterName,
    );
  }

  Future<List<Poem>> _localPoems({
    String? categoryId,
    String? q,
  }) async {
    List<Poem> poems;
    if (categoryId != null && categoryId.isNotEmpty) {
      poems = await _db.getPoemsByCategoryId(categoryId);
    } else {
      poems = await _db.getCachedPoems();
    }
    if (q == null || q.trim().isEmpty) return poems;
    final query = q.trim().toLowerCase();
    return poems
        .where((p) =>
            p.title.toLowerCase().contains(query) ||
            p.content.toLowerCase().contains(query))
        .toList();
  }
}