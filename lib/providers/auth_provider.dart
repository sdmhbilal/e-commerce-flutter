import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';
import '../core/api_client.dart';
import '../core/http_utils.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() : _api = ApiClient(AppConfig.apiBaseUrl);

  final ApiClient _api;

  String? _token;
  String? get token => _token;
  bool get isAuthed => _token != null && _token!.isNotEmpty;

  /// Profile from GET /api/auth/me/ (id, username, email)
  Map<String, dynamic>? userProfile;
  bool profileLoading = false;
  String? profileError;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (isAuthed) loadProfile();
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (!isAuthed) return;
    profileLoading = true;
    profileError = null;
    notifyListeners();
    try {
      final res = await _api.get('/api/auth/me/', auth: true);
      if (res.statusCode >= 400) {
        profileError = errorFromResponse(res).message;
        notifyListeners();
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      userProfile = data;
    } catch (e) {
      profileError = e.toString();
    }
    profileLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    if (isAuthed) {
      try {
        await _api.post('/api/auth/logout/', auth: true);
      } catch (_) {
        // Always clear local token even if backend call fails
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    userProfile = null;
    profileError = null;
    notifyListeners();
  }

  /// Register: sends OTP to email. Returns email on success. User must then call verifyEmail.
  Future<String> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final res = await _api.post('/api/auth/register/', body: {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
    });
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['email'] as String?) ?? email;
  }

  /// Verify email with OTP; on success saves token and loads profile.
  Future<void> verifyEmail({required String email, required String otp}) async {
    final res = await _api.post('/api/auth/verify-email/', body: {
      'email': email,
      'otp': otp,
    });
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveToken(data['token'] as String);
    await loadProfile();
  }

  /// Update profile. If backend returns [pending_email], caller should show OTP step and call [verifyEmailChange].
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (!isAuthed) return {};
    final body = <String, String>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (email != null) body['email'] = email;
    final res = await _api.patch('/api/auth/profile/', auth: true, body: body);
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await loadProfile();
    return data;
  }

  /// Verify new email with OTP after requesting email change; then refreshes profile.
  Future<void> verifyEmailChange({required String newEmail, required String otp}) async {
    final res = await _api.post('/api/auth/verify-email-change/', body: {
      'new_email': newEmail,
      'otp': otp,
    }, auth: true);
    if (res.statusCode >= 400) throw errorFromResponse(res);
    await loadProfile();
  }

  /// Upload avatar image (bytes + filename from image_picker). Refreshes profile on success.
  Future<void> uploadAvatar({required List<int> bytes, required String filename}) async {
    if (!isAuthed) return;
    final streamed = await _api.postMultipart(
      '/api/auth/profile/avatar/',
      bytes: bytes,
      filename: filename,
      auth: true,
    );
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    userProfile = data;
    notifyListeners();
  }

  Future<void> login({required String username, required String password}) async {
    final res = await _api.post('/api/auth/login/', body: {
      'username': username,
      'password': password,
    });
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveToken(data['token'] as String);
    await loadProfile();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
    notifyListeners();
  }
}

