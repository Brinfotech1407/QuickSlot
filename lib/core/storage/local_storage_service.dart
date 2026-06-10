import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = 'auth_token';

  late final SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String? getToken() => _preferences.getString(_tokenKey);

  Future<bool> setToken(String token) {
    return _preferences.setString(_tokenKey, token);
  }

  Future<bool> clearToken() {
    return _preferences.remove(_tokenKey);
  }

  String? getString(String key) => _preferences.getString(key);

  Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  Future<bool> remove(String key) => _preferences.remove(key);
}
