import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/service/storage_service.dart';
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
    final savedLocale = await StorageService.getSavedLocale();
    if (savedLocale != null) {
      _currentLocale = Locale(
        savedLocale['languageCode']!,
        savedLocale['countryCode']!.isEmpty ? null : savedLocale['countryCode'],
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
    await StorageService.saveLocale(
      locale.languageCode,
      locale.countryCode,
    );
    notifyListeners();
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    _currentLocale = null;
    await StorageService.clearLocale();
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