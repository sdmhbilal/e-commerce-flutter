import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';
import '../constants/app_constants.dart';

const Duration _kRequestTimeout = Duration(seconds: 30);

String _normalizeBaseUrl(String url) {
  final u = url.trim();
  return u.endsWith('/') ? u.substring(0, u.length - 1) : u;
}

class ApiClient {
  ApiClient([String? baseUrl])
      : baseUrl = _normalizeBaseUrl(baseUrl ?? Env.apiBaseUrl);

  final String baseUrl;

  Future<http.StreamedResponse> postMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    String field = 'avatar',
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    final headers = await _headers(auth: auth, cart: false);
    request.headers.addAll(Map<String, String>.from(headers));
    request.headers.remove('Content-Type');
    request.files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
    return request.send().timeout(_kRequestTimeout);
  }

  Future<http.Response> get(String path, {bool auth = false, bool cart = false}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth, cart: cart);
    return http.get(uri, headers: headers).timeout(_kRequestTimeout);
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool auth = false,
    bool cart = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth, cart: cart);
    return http
        .post(uri, headers: headers, body: jsonEncode(body ?? {}))
        .timeout(_kRequestTimeout);
  }

  Future<http.Response> patch(
    String path, {
    Object? body,
    bool auth = false,
    bool cart = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth, cart: cart);
    return http
        .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
        .timeout(_kRequestTimeout);
  }

  Future<http.Response> delete(String path, {bool auth = false, bool cart = false  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth, cart: cart);
    return http.delete(uri, headers: headers).timeout(_kRequestTimeout);
  }

  Future<Map<String, String>> _headers({required bool auth, required bool cart}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);
    final cartToken = prefs.getString(StorageKeys.cartToken);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'ECommerceFlutter/1.0',
    };
    if (auth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Token $token';
    }
    if (cart && cartToken != null && cartToken.isNotEmpty) {
      headers['X-Cart-Token'] = cartToken;
    }
    return headers;
  }
}
