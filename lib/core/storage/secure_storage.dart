import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Optional init for platform-specific setups
  static Future<void> init() async {
    // nothing for now
  }

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
