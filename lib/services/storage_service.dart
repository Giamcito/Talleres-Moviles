import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyTheme = 'theme';
  static const _keyLanguage = 'language';

  const StorageService();

  FlutterSecureStorage get _secure => const FlutterSecureStorage();

  Future<void> saveUserInfo({String? name, String? email, String? theme, String? language}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyName, name);
    if (email != null) await prefs.setString(_keyEmail, email);
    if (theme != null) await prefs.setString(_keyTheme, theme);
    if (language != null) await prefs.setString(_keyLanguage, language);
  }

  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName),
      'email': prefs.getString(_keyEmail),
      'theme': prefs.getString(_keyTheme),
      'language': prefs.getString(_keyLanguage),
    };
  }

  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyTheme);
    await prefs.remove(_keyLanguage);
  }

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _secure.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _secure.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    return _secure.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _secure.read(key: _keyRefreshToken);
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _secure.delete(key: _keyAccessToken);
    await _secure.delete(key: _keyRefreshToken);
  }
}
