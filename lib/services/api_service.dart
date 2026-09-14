import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/poem.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? kApiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const Duration _timeout = Duration(seconds: 10);

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<List<Category>> getCategories() async {
    final res = await _client.get(_uri('/categories')).timeout(_timeout);
    final data = _decodeList(res);
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Poem>> getPoems({String? categoryId, String? q}) async {
    final query = <String, String>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      query['categoryId'] = categoryId;
    }
    if (q != null && q.trim().isNotEmpty) {
      query['q'] = q.trim();
    }
    final res = await _client.get(
      _uri('/poems', query.isEmpty ? null : query),
    ).timeout(_timeout);
    final data = _decodeList(res);
    return data
        .map((e) => Poem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Poem> getPoem(String id) async {
    final res = await _client.get(_uri('/poems/$id')).timeout(_timeout);
    final data = _decodeMap(res);
    return Poem.fromJson(data);
  }

  /// Flutter "Write" → admin verification queue.
  Future<Map<String, dynamic>> createSubmission({
    required String title,
    required String content,
    required String categoryId,
    String? submitterName,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'content': content,
      'categoryId': categoryId,
    };
    if (submitterName != null && submitterName.trim().isNotEmpty) {
      body['submitterName'] = submitterName.trim();
    }
    final res = await _client.post(
      _uri('/submissions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _decodeMap(res);
  }

  List<dynamic> _decodeList(http.Response res) {
    final decoded = _decode(res);
    if (decoded is! List) {
      throw ApiException('Unexpected response shape');
    }
    return decoded;
  }

  Map<String, dynamic> _decodeMap(http.Response res) {
    final decoded = _decode(res);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape');
    }
    return decoded;
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Request failed (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] != null) {
          final m = body['message'];
          message = m is List ? m.join(', ') : m.toString();
        }
      } catch (_) {}
      throw ApiException(message, statusCode: res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}
