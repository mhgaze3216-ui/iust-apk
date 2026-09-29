import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.statusCode, this.code, this.message, {this.details});

  final int statusCode;
  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'iust_access_token';
  static const _refreshTokenKey = 'iust_refresh_token';
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  final http.Client _http = http.Client();
  Future<String?>? _refreshInProgress;

  Uri _uri(String path, [Map<String, String>? query]) {
    final rawBase = Uri.parse(_baseUrl);
    final base = rawBase.path.endsWith('/')
        ? rawBase
        : rawBase.replace(path: '${rawBase.path}/');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(normalizedPath).replace(queryParameters: query);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) =>
      _request('POST', path, body: body, query: query);

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) =>
      _request('PATCH', path, body: body, query: query);

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) =>
      _request('PUT', path, body: body, query: query);

  Future<void> delete(String path, {Object? body}) async {
    await _request('DELETE', path, body: body);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool retryUnauthorized = true,
  }) async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final uri = _uri(path, query);

    Future<http.Response> send() {
      switch (method) {
        case 'GET':
          return _http.get(uri, headers: headers);
        case 'POST':
          return _http.post(uri, headers: headers, body: jsonEncode(body));
        case 'PATCH':
          return _http.patch(uri, headers: headers, body: jsonEncode(body));
        case 'PUT':
          return _http.put(uri, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          return _http.delete(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        default:
          throw ArgumentError.value(method, 'method', 'Unsupported HTTP method.');
      }
    }

    var response = await send();
    if (response.statusCode == 401 &&
        retryUnauthorized &&
        path != '/auth/login' &&
        path != '/auth/refresh') {
      final refreshed = await _refreshAccessToken();
      if (refreshed != null) {
        headers['Authorization'] = 'Bearer $refreshed';
        response = await send();
      }
    }
    if (response.statusCode == 204 || response.body.isEmpty) {
      if (response.statusCode >= 400) {
        throw ApiException(response.statusCode, 'HTTP_ERROR', 'The request failed.');
      }
      return <String, dynamic>{};
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(response.statusCode, 'INVALID_RESPONSE', 'The server returned invalid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(response.statusCode, 'INVALID_RESPONSE', 'The server returned an unexpected response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        throw ApiException(
          response.statusCode,
          error['code']?.toString() ?? 'HTTP_ERROR',
          error['message']?.toString() ?? 'The request failed.',
          details: error['details'],
        );
      }
      throw ApiException(response.statusCode, 'HTTP_ERROR', 'The request failed.');
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;
    return decoded;
  }

  Future<String?> _refreshAccessToken() async {
    final current = _refreshInProgress;
    if (current != null) return current;

    final refresh = _storage.read(key: _refreshTokenKey);
    final future = refresh.then((refreshToken) async {
      if (refreshToken == null) return null;
      try {
        final response = await _http.post(
          _uri('/auth/refresh'),
          headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
        if (response.statusCode != 200) {
          await clearTokens();
          return null;
        }
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic> ||
            decoded['data'] is! Map<String, dynamic>) {
          throw const ApiException(502, 'INVALID_RESPONSE', 'The refresh response is invalid.');
        }
        final data = decoded['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String?;
        final rotatedRefreshToken = data['refreshToken'] as String?;
        if (accessToken == null || rotatedRefreshToken == null) {
          throw const ApiException(502, 'INVALID_RESPONSE', 'The refresh response is incomplete.');
        }
        await saveTokens(accessToken: accessToken, refreshToken: rotatedRefreshToken);
        return accessToken;
      } catch (error) {
        if (error is ApiException) rethrow;
        if (kDebugMode) debugPrint('Token refresh failed: $error');
        await clearTokens();
        return null;
      }
    });
    _refreshInProgress = future;
    try {
      return await future;
    } finally {
      _refreshInProgress = null;
    }
  }

  void close() => _http.close();
}
