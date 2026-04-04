import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String authTokenKey = 'auth_token';

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: authTokenKey, value: token);
  }

  static Future<String?> readAuthToken() async {
    return _storage.read(key: authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    await _storage.delete(key: authTokenKey);
  }
}
