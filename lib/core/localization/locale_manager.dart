import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

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
    try {
      final savedLocale = await SecureStorageService().get(StorageKeys.localeKey);
      if (savedLocale != null) {
        final parts = savedLocale.split('_');
        _currentLocale = Locale(
          parts[0],
          parts.length > 1 ? parts[1] : null,
        );
      }
    } on Exception catch (e) {
      logE('Error initializing locale: $e');
    }
    notifyListeners();
  }

  /// Change the app locale
  Future<void> setLocale(Locale locale) async {
    if (!SupportedLocales.supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }

    _currentLocale = locale;

    try {
      await SecureStorageService().save(StorageKeys.localeKey, locale.languageCode);
    } on Exception catch (e) {
      logE('Error saving locale: $e');
    }
    notifyListeners();
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    _currentLocale = null;
    try {
      await SecureStorageService().remove(StorageKeys.localeKey);
    } on Exception catch (e) {
      logE('Error removing locale: $e');
    }
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