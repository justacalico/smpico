import 'package:shared_preferences/shared_preferences.dart';
import 'i18n.dart';

class Settings {
  Settings._();
  static final Settings instance = Settings._();

  late SharedPreferences _p;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    final l = get<String>('language', 'en');
    I18n.instance.setLang(l == 'ru' ? AppLang.ru : AppLang.en);
  }

  T get<T>(String key, T fallback) {
    final v = _p.get(key);
    if (v is T) return v;
    return fallback;
  }

  Future<void> set(String key, Object? value) async {
    if (value == null) {
      await _p.remove(key);
    } else if (value is bool) {
      await _p.setBool(key, value);
    } else if (value is int) {
      await _p.setInt(key, value);
    } else if (value is double) {
      await _p.setDouble(key, value);
    } else if (value is String) {
      await _p.setString(key, value);
    } else if (value is List<String>) {
      await _p.setStringList(key, value);
    }
  }

  bool contains(String key) => _p.containsKey(key);

  Future<void> remove(String key) => _p.remove(key);

  Future<void> resetAll() => _p.clear();
}
