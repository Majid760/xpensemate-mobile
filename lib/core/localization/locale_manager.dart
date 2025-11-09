import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

class LocaleManager extends ChangeNotifier {
  factory LocaleManager() => _instance;
  LocaleManager._internal();
  static final LocaleManager _instance = LocaleManager._internal();

  static const Locale _defaultLocale = Locale('en', 'US'); // Default English
  Locale _currentLocale = _defaultLocale;

  Locale get currentLocale => _currentLocale;
  bool get isRTL => SupportedLocales.isRTL(_currentLocale);

  /// Initialize locale - load from storage or use default
  Future<void> initialize() async {
    try {
      final savedLocale = await SecureStorageService.instance.read(StorageKeys.locale);

      if (savedLocale != null) {
        _currentLocale = _parseLocale(savedLocale) ?? _defaultLocale;
      } else {
        // No saved locale - use default and save it
        _currentLocale = _defaultLocale;
        await _saveCurrentLocale();
      }
    } on Exception catch (e) {
      logE('Error initializing locale: $e');
      _currentLocale = _defaultLocale;
    }
    notifyListeners();
  }

  /// Set new locale
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }

    _currentLocale = locale;
    await _saveCurrentLocale();
    notifyListeners();
  }

  /// Reset to default locale
  Future<void> resetToDefault() async {
    _currentLocale = _defaultLocale;
    await _saveCurrentLocale();
    notifyListeners();
  }

  /// Parse locale string to Locale object
  Locale? _parseLocale(String localeString) {
    try {
      // Handle both formats: "en" or "en_US"
      if (localeString.contains('_')) {
        final parts = localeString.split('_');
        final locale = Locale(parts[0], parts[1]);
        return _isSupported(locale) ? locale : null;
      } else {
        // Just language code - find matching supported locale
        final locale = SupportedLocales.supportedLocales.where((l) => l.languageCode == localeString).firstOrNull;
        return locale;
      }
    } on Exception catch (e) {
      logE('Error parsing locale string: $localeString, error: $e');
      return null;
    }
  }

  /// Save current locale to storage
  Future<void> _saveCurrentLocale() async {
    try {
      // Use only language code to avoid storage issues
      final localeString = _currentLocale.languageCode;
      logD('Saving locale: $localeString');
      await SecureStorageService.instance.write(StorageKeys.locale, localeString);
      logD('Locale saved: $localeString');
    } on Exception catch (e) {
      logE('Error saving locale: $e');
      // Don't throw - continue with in-memory locale
    }
  }

  /// Check if locale is supported
  bool _isSupported(Locale locale) => SupportedLocales.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode && supported.countryCode == locale.countryCode,
      );

  /// Get locale from language code (helper method)
  Locale? getLocaleFromLanguageCode(String languageCode) =>
      SupportedLocales.supportedLocales.where((locale) => locale.languageCode == languageCode).firstOrNull;
}
