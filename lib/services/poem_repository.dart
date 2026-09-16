import '../db/db_helper.dart';
import '../models/category.dart';
import '../models/poem.dart';
import 'api_service.dart';

/// Offline-first data access for the poem catalog.
///
/// Reads the local SQLite cache first so the app works with no internet
/// connection, then refreshes from the remote API in the background. When the
/// cache is empty (first launch) it loads straight from the server. Requests
/// are never cut short by a client-side timeout, so slow connections can
/// finish loading.
class PoemRepository {
  PoemRepository({ApiService? api, DBHelper? db})
      : _api = api ?? ApiService(),
        _db = db ?? DBHelper();

  final ApiService _api;
  final DBHelper _db;

  Future<({List<Category> categories, Map<String, int> counts})>
      getCategoriesWithCounts({bool forceRefresh = false}) async {
    final categories = await getCategories(forceRefresh: forceRefresh);
    final poems = await getPoems(forceRefresh: forceRefresh);
    final counts = <String, int>{};
    for (final p in poems) {
      final id = p.categoryId;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return (categories: categories, counts: counts);
  }

  Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return _loadCategoriesFromServer();
    }
    final cached = await _db.getCachedCategories();
    if (cached.isNotEmpty) {
      _loadCategoriesFromServer().then((_) {}, onError: (_) {});
      return cached;
    }
    return _loadCategoriesFromServer();
  }

  Future<List<Category>> _loadCategoriesFromServer() async {
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

  Future<List<Poem>> getPoems({
    String? categoryId,
    String? q,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      return _loadPoemsFromServer(categoryId: categoryId, q: q);
    }
    final cached = await _localPoems(categoryId: categoryId, q: q);
    if (cached.isNotEmpty) {
      _loadPoemsFromServer(categoryId: categoryId, q: q)
          .then((_) {}, onError: (_) {});
      return cached;
    }
    return _loadPoemsFromServer(categoryId: categoryId, q: q);
  }

  Future<List<Poem>> _loadPoemsFromServer({
    String? categoryId,
    String? q,
  }) async {
    try {
      final poems = await _api.getPoems(categoryId: categoryId, q: q);
      final isFullFetch =
          (categoryId == null || categoryId.isEmpty) &&
          (q == null || q.trim().isEmpty);
      if (isFullFetch) {
        await _db.cacheAllPoems(poems);
      } else {
        await _db.cachePoems(poems);
      }
      return poems;
    } catch (_) {
      final cached = await _localPoems(categoryId: categoryId, q: q);
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  Future<Poem> getPoem(String id) async {
    final cached = await _db.getCachedPoems();
    final existing = cached.where((p) => p.id == id).toList();
    if (existing.isNotEmpty) {
      _loadPoemFromServer(id).then((_) {}, onError: (_) {});
      return existing.first;
    }
    return _loadPoemFromServer(id);
  }

  Future<Poem> _loadPoemFromServer(String id) async {
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

  Future<List<Poem>> searchPoems(
    String query, {
    bool forceRefresh = false,
  }) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim();
    if (forceRefresh) {
      return _searchFromServer(q);
    }
    final cached = await _db.searchPoems(q);
    _searchFromServer(q).then((_) {}, onError: (_) {});
    return cached;
  }

  Future<List<Poem>> _searchFromServer(String q) async {
    try {
      final results = await _api.getPoems(q: q);
      await _db.cachePoems(results);
      final cached = await _db.searchPoems(q);
      if (cached.isEmpty) return results;

      // Merge: server results first, local-only matches appended so nothing a
      // user can see on-device is hidden behind a flaky server call.
      final seen = <String>{};
      for (final p in results) {
        if (p.id != null) seen.add(p.id!);
      }
      final merged = <Poem>[...results];
      for (final p in cached) {
        if (p.id == null || seen.add(p.id!)) merged.add(p);
      }
      return merged;
    } catch (_) {
      return _db.searchPoems(q);
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