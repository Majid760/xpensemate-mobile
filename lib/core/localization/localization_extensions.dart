import 'package:flutter/material.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

extension LocalizationContext on BuildContext {
  /// Get the current app localizations
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  /// Get the current locale
  Locale get locale => Localizations.localeOf(this);
  
  /// Check if current locale is RTL
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
  
  /// Get text direction based on locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
  
  /// Localization shortcuts for common strings
  String get appTitle => l10n.appTitle;
  String get home => l10n.home;
  String get profile => l10n.profile;
  String get settings => l10n.settings;
  String get about => l10n.about;
  
  // Common actions
  String get save => l10n.save;
  String get cancel => l10n.cancel;
  String get delete => l10n.delete;
  String get edit => l10n.edit;
  String get add => l10n.add;
  String get confirm => l10n.confirm;
  String get retry => l10n.retry;
  String get close => l10n.close;
  String get next => l10n.next;
  String get back => l10n.back;
  String get done => l10n.done;
  String get loading => l10n.loading;
  
  // Authentication
  String get login => l10n.login;
  String get logout => l10n.logout;
  String get register => l10n.register;
  String get email => l10n.email;
  String get password => l10n.password;
  String get confirmPassword => l10n.confirmPassword;
  String get forgotPassword => l10n.forgotPassword;
  String get welcomeBack => l10n.welcomeBack;
  String get createAccount => l10n.createAccount;
  
  // Validation
  String get fieldRequired => l10n.fieldRequired;
  String get invalidEmail => l10n.invalidEmail;
  String get passwordTooShort => l10n.passwordTooShort;
  String get passwordsDoNotMatch => l10n.passwordsDoNotMatch;
  
  // Errors
  String get errorGeneric => l10n.errorGeneric;
  String get errorNetwork => l10n.errorNetwork;
  String get errorTimeout => l10n.errorTimeout;
  String get errorNotFound => l10n.errorNotFound;
  
  // Success messages
  String get saveSuccess => l10n.saveSuccess;
  String get deleteSuccess => l10n.deleteSuccess;
  String get updateSuccess => l10n.updateSuccess;
  
  // Placeholders
  String get searchPlaceholder => l10n.searchPlaceholder;
  String get noDataAvailable => l10n.noDataAvailable;
  String get emptyListMessage => l10n.emptyListMessage;
  
  // Dialogs
  String get confirmDelete => l10n.confirmDelete;
  String get confirmLogout => l10n.confirmLogout;
  String get deleteWarning => l10n.deleteWarning;
  
  // Theme
  String get themeMode => l10n.themeMode;
  String get lightTheme => l10n.lightTheme;
  String get darkTheme => l10n.darkTheme;
  String get systemTheme => l10n.systemTheme;
  
  // Language
  String get language => l10n.language;
  String get selectLanguage => l10n.selectLanguage;
  String get languageChanged => l10n.languageChanged;
}

extension LocalizationHelpers on BuildContext {
  /// Welcome user with parametrized message
  String welcomeUser(String userName) => l10n.welcomeUser(userName);
  
  /// Item count with pluralization
  String itemCount(int count) => l10n.itemCount(count);
  
  /// Last updated with date formatting
  String lastUpdated(DateTime date) => l10n.lastUpdated(date);
}