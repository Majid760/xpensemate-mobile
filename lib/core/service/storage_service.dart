import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _localeKey = 'selected_locale';
  static const String _themeKey = 'theme_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Locale Storage
  static Future<void> saveLocale(String languageCode, [String? countryCode]) async {
    await init();
    final localeString = countryCode != null 
        ? '${languageCode}_$countryCode' 
        : languageCode;
    await _prefs!.setString(_localeKey, localeString);
  }

  static Future<Map<String, String>?> getSavedLocale() async {
    await init();
    final localeString = _prefs!.getString(_localeKey);
    if (localeString == null) return null;

    final parts = localeString.split('_');
    return {
      'languageCode': parts[0],
      'countryCode': parts.length > 1 ? parts[1] : '',
    };
  }

  static Future<void> clearLocale() async {
    await init();
    await _prefs!.remove(_localeKey);
  }

  // Theme Storage
  static Future<void> saveThemeMode(String themeMode) async {
    await init();
    await _prefs!.setString(_themeKey, themeMode);
  }

  static Future<String?> getSavedThemeMode() async {
    await init();
    return _prefs!.getString(_themeKey);
  }
}