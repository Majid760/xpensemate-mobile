import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
class LocaleManager extends ChangeNotifier {
  factory LocaleManager() => _instance;
  LocaleManager._internal();
  static final LocaleManager _instance = LocaleManager._internal();

  Locale? _currentLocale;
  
  Locale? get currentLocale => _currentLocale;
  
  bool get isRTL => _currentLocale != null && 
      SupportedLocales.isRTL(_currentLocale!);

  /// Initialize the locale manager
  Future<void> initialize() async {
    final savedLocale = await SecureStorageService().get(StorageKeys.localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      _currentLocale = Locale(
        parts[0],
        parts.length > 1 ? parts[1] : null,
      );
    }
    notifyListeners();
  }

  /// Change the app locale
  Future<void> setLocale(Locale locale) async {
    if (!SupportedLocales.supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }

    _currentLocale = locale;

    await SecureStorageService().save(StorageKeys.localeKey, locale.languageCode);
    notifyListeners();
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    _currentLocale = null;
    await SecureStorageService().remove(StorageKeys.localeKey);
    notifyListeners();
  }

  /// Get locale from language code
  Locale? getLocaleFromLanguageCode(String languageCode) {
    try {
      return SupportedLocales.supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
      );
    } on ArgumentError {
      return null;
    }
  }

  /// Check if a locale is supported
  bool isLocaleSupported(Locale locale) => SupportedLocales.supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode,
    );
}