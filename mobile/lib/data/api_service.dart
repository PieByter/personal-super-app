import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _accessToken;
  String? _refreshToken;

  /// Called when the API returns 401 and refresh fails (expired session).
  /// The app sets this to redirect the user to the login screen.
  VoidCallback? onUnauthorized;

  /// Guards concurrent refresh calls so only one refresh runs at a time.
  Future<bool>? _refreshing;

  Future<void> init() async {
    _accessToken = await _storage.read(key: StorageKeys.accessToken);
    _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<bool> isLoggedIn() async {
    if (_accessToken != null) return true;
    _accessToken = await _storage.read(key: StorageKeys.accessToken);
    return _accessToken != null;
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> get(String url) =>
      _send(() => http.get(Uri.parse(url), headers: _headers));

  Future<dynamic> post(String url, Map<String, dynamic> body) => _send(
        () => http.post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        ),
      );

  Future<dynamic> put(String url, Map<String, dynamic> body) => _send(
        () => http.put(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        ),
      );

  Future<dynamic> delete(String url) =>
      _send(() => http.delete(Uri.parse(url), headers: _headers));

  /// Sends a request; on 401 it attempts a single token refresh and retries once.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    var response = await request();

    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await request();
      }
    }

    return _handleResponse(response);
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true on success. Only one refresh runs at a time.
  Future<bool> _tryRefresh() async {
    if (_refreshing != null) {
      return _refreshing!;
    }

    final refreshToken = _refreshToken;
    if (refreshToken == null) {
      _forceLogout();
      return false;
    }

    _refreshing = _doRefresh(refreshToken);
    try {
      return await _refreshing!;
    } finally {
      _refreshing = null;
    }
  }

  Future<bool> _doRefresh(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode != 200) {
        _forceLogout();
        return false;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await setTokens(data['accessToken'], data['refreshToken']);
      return true;
    } catch (_) {
      _forceLogout();
      return false;
    }
  }

  void _forceLogout() {
    clearTokens();
    onUnauthorized?.call();
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Refresh already attempted and failed.
      _forceLogout();
      throw Exception('Session expired. Please login again.');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    throw Exception('API Error ${response.statusCode}: ${response.body}');
  }
}
