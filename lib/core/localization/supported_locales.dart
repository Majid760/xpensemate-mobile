import 'dart:ui';

class SupportedLocales {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (US)
    Locale('es', 'ES'), // Spanish (Spain)
    Locale('fr', 'FR'), // French (France)
    Locale('ar', 'SA'), // Arabic (Saudi Arabia)
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'ar': 'العربية',
  };

  static const Map<String, String> countryNames = {
    'US': 'United States',
    'ES': 'España',
    'FR': 'France',
    'SA': 'المملكة العربية السعودية',
  };

  static const List<String> rtlLanguages = ['ar', 'he', 'fa', 'ur'];

  static bool isRTL(Locale locale) => rtlLanguages.contains(locale.languageCode);

  static String getLanguageName(String languageCode) => languageNames[languageCode] ?? languageCode;

  static String getCountryName(String countryCode) => countryNames[countryCode] ?? countryCode;

  static String getDisplayName(Locale locale) {
    final language = getLanguageName(locale.languageCode);
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      final country = getCountryName(locale.countryCode!);
      return '$language ($country)';
    }
    return language;
  }
}