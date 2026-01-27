import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service using SharedPreferences
@singleton
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  /// Save integer value
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get integer value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save boolean value
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Remove value
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all values
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
