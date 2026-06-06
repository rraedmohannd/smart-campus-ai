import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  const ApiClient();

  Uri _uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {String? token}) async {
    final response = await http.get(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decode(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.put(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {String? token}) async {
    final response = await http.delete(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final body = response.body.trim();
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    dynamic decoded;

    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (!ok) {
      final message = decoded is Map
          ? (decoded['detail'] ?? decoded['message'] ?? decoded['error'])
              .toString()
          : 'Request failed with status ${response.statusCode}';
      throw ApiException(response.statusCode, message);
    }

    return decoded;
  }

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> asMapList(dynamic value) {
    final list = asList(value);
    return list.map((item) => asMap(item)).toList();
  }

  static List<dynamic> asList(dynamic value) {
    if (value is List) return value;
    if (value is Map) {
      for (final key in const [
        'items',
        'data',
        'results',
        'records',
        'buses',
        'books',
        'users',
        'students',
        'notifications',
        'reservations',
        'borrowings',
        'logs',
        'categories',
        'rules',
      ]) {
        final nested = value[key];
        if (nested is List) return nested;
      }
    }
    return const [];
  }
}
