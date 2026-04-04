import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  SecureStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static String? _webAuthToken;

  static const String authTokenKey = 'auth_token';

  static Future<void> saveAuthToken(String token) async {
    if (kIsWeb) {
      _webAuthToken = token;
      return;
    }
    await _storage.write(key: authTokenKey, value: token);
  }

  static Future<String?> readAuthToken() async {
    if (kIsWeb) {
      return _webAuthToken;
    }
    return _storage.read(key: authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    if (kIsWeb) {
      _webAuthToken = null;
      return;
    }
    await _storage.delete(key: authTokenKey);
  }
}
