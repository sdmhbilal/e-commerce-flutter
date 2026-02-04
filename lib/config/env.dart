import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static const String _defaultApiBaseUrl = 'http://127.0.0.1:8000';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL']?.trim().isNotEmpty == true
          ? dotenv.env['API_BASE_URL']!.trim()
          : _defaultApiBaseUrl;
}
