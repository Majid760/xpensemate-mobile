// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Xpensemate';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get or => 'Or';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get hintEmail => 'email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get hintConfirmPassword => 'Re-enter password';

  @override
  String get name => 'Full Name';

  @override
  String get hintName => 'full name';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get registerNow => 'Create Account';

  @override
  String get hintPassword => 'password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Reset Your Password';

  @override
  String get forgotPasswordSubtitle => 'Enter your email and we\'ll send you a link to reset your password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSuccess => 'Password reset email sent. Please check your inbox.';

  @override
  String get rememberPassword => 'Remember your password?';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get createAccount => 'Create Account';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get verificationEmailSentTo => 'Verification email sent to';

  @override
  String get verificationInstructions => 'Please check your email for the verification link.';

  @override
  String get resendVerificationEmail => 'Resend Verification Email';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get passwordOrEmail => 'Password or Email is incorrect!';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerSuccess => 'Account created successfully!';

  @override
  String get verifyEmail => 'We have sent a verification email to your email address. Please check your inbox.';

  @override
  String get verifyEmailSuccess => 'Email verification sent successfully!';

  @override
  String get verifyEmailFailed => 'Email verification failed. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorTimeout => 'Request timeout. Please try again.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get saveSuccess => 'Saved successfully!';

  @override
  String get deleteSuccess => 'Deleted successfully!';

  @override
  String get updateSuccess => 'Updated successfully!';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get emptyListMessage => 'Nothing to show here yet';

  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get deleteWarning => 'This action cannot be undone.';

  @override
  String welcomeUser(String userName) {
    return 'Welcome, $userName!';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last updated: $dateString';
  }

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get thisMonth => 'This Month';

  @override
  String get categories => 'Categories';

  @override
  String get account => 'Account';

  @override
  String get preferences => 'Preferences';

  @override
  String get support => 'Support';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updatePersonalInfo => 'Update your personal information';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get managePrivacySettings => 'Manage your privacy settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get configureNotifications => 'Configure your notifications';

  @override
  String get choosePreferredLanguage => 'Choose your preferred language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get switchBetweenLightAndDarkTheme => 'Switch between light and dark theme';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get getHelpWhenNeeded => 'Get help when you need it';

  @override
  String get learnMoreAboutExpenseTracker => 'Learn more about Xpensemate';

  @override
  String get signOut => 'Sign Out';

  @override
  String get logoutFromAccount => 'Logout from your account';

  @override
  String get expenseTracker => 'Xpensemate';

  @override
  String get version => 'Version 1.0.0 • Build 2024.1';

  @override
  String get craftedWithLove => 'Crafted with ❤️ for smarter expense tracking';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get gotIt => 'Got it!';

  @override
  String get areYouSureYouWantToSignOut => 'Are you sure you want to sign out?';

  @override
  String get comingSoonMessage => 'This amazing feature is coming soon!\nStay tuned for updates.';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get signOutConfirmationMessage => 'You will be signed out of your account and need to sign in again to continue.';

  @override
  String get signOutConfirmationButton => 'Sign Out';

  @override
  String get signOutConfirmationCancel => 'Cancel';

  @override
  String get selectImage => 'Select Image';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRationale => 'We need this permission to provide you with the best experience.';

  @override
  String get notNow => 'Not Now';

  @override
  String get proceed => 'Continue';

  @override
  String get openSettings => 'Settings';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionDeniedMessage => 'Please enable this permission from settings to use this feature.';

  @override
  String get cameraPermissionMessage => 'We need camera access to take photos.';

  @override
  String get galleryPermissionMessage => 'We need gallery access to choose photos.';
}
