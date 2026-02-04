import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiError implements Exception {
  ApiError(this.message);
  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> decodeJson(http.Response res) {
  if (res.body.isEmpty) return <String, dynamic>{};
  return jsonDecode(res.body) as Map<String, dynamic>;
}

List<dynamic> decodeJsonList(http.Response res) {
  if (res.body.isEmpty) return <dynamic>[];
  return jsonDecode(res.body) as List<dynamic>;
}

ApiError errorFromResponse(http.Response res) {
  try {
    final data = decodeJson(res);
    if (data['detail'] is String) return ApiError(data['detail'] as String);
    return ApiError('Request failed (${res.statusCode}).');
  } catch (_) {
    return ApiError('Request failed (${res.statusCode}).');
  }
}

