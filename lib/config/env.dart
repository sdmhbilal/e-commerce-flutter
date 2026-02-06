import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static const String _defaultApiBaseUrl = 'http://127.0.0.1:8000';

  /// API base URL. Prefers --dart-define=API_BASE_URL=... (release builds),
  /// then .env API_BASE_URL, then default localhost.
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (fromDefine.trim().isNotEmpty) return fromDefine.trim();
    if (dotenv.env['API_BASE_URL']?.trim().isNotEmpty == true) {
      return dotenv.env['API_BASE_URL']!.trim();
    }
    return _defaultApiBaseUrl;
  }
}
