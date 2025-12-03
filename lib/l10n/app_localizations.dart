import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Xpensemate'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Save button text used throughout the app
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @expenseLoaded.
  ///
  /// In en, this message translates to:
  /// **'All expenses loaded successfully!'**
  String get expenseLoaded;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully!'**
  String get expenseDeleted;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully!'**
  String get expenseUpdated;

  /// No description provided for @expenseCreated.
  ///
  /// In en, this message translates to:
  /// **'Expense created successfully!'**
  String get expenseCreated;

  /// No description provided for @expenseFailed.
  ///
  /// In en, this message translates to:
  /// **'Expense failed to load!'**
  String get expenseFailed;

  /// No description provided for @expenseDeletedFailed.
  ///
  /// In en, this message translates to:
  /// **'Expense failed to delete!'**
  String get expenseDeletedFailed;

  /// No description provided for @expenseUpdatedFailed.
  ///
  /// In en, this message translates to:
  /// **'Expense failed to update!'**
  String get expenseUpdatedFailed;

  /// No description provided for @expenseCreatedFailed.
  ///
  /// In en, this message translates to:
  /// **'Expense failed to create!'**
  String get expenseCreatedFailed;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get currencySymbol;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email input field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get hintEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @hintConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get hintConfirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'full name'**
  String get hintName;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerNow;

  /// Hint text for password input field
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get hintPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get resetPasswordSuccess;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to'**
  String get verificationEmailSentTo;

  /// No description provided for @verificationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your email for the verification link.'**
  String get verificationInstructions;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @passwordOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Password or Email is incorrect!'**
  String get passwordOrEmail;

  /// Error message when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Error message when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get registerSuccess;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification email to your email address. Please check your inbox.'**
  String get verifyEmail;

  /// No description provided for @verifyEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verification sent successfully!'**
  String get verifyEmailSuccess;

  /// No description provided for @verifyEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Email verification failed. Please try again.'**
  String get verifyEmailFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errorNotFound;

  /// No description provided for @budgetGoalsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get budgetGoalsLoading;

  /// No description provided for @budgetGoalsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get budgetGoalsRetry;

  /// No description provided for @budgetGoalsError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get budgetGoalsError;

  /// No description provided for @budgetGoalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No budget goals yet'**
  String get budgetGoalsEmptyTitle;

  /// No description provided for @budgetGoalsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first budget goal to get started'**
  String get budgetGoalsEmptySubtitle;

  /// No description provided for @budgetGoalsAllLoaded.
  ///
  /// In en, this message translates to:
  /// **'All budget goals loaded'**
  String get budgetGoalsAllLoaded;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully!'**
  String get saveSuccess;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully!'**
  String get deleteSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully!'**
  String get updateSuccess;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @emptyListMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show here yet'**
  String get emptyListMessage;

  /// Confirmation dialog when user tries to delete an item
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteWarning;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}!'**
  String welcomeUser(String userName);

  /// Shows count of items with proper pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// Shows when something was last updated
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(DateTime date);

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @budgetGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget Goal: {amount}'**
  String budgetGoalLabel(Object amount);

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updatePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @managePrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get managePrivacySettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @configureNotifications.
  ///
  /// In en, this message translates to:
  /// **'Configure your notifications'**
  String get configureNotifications;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @switchBetweenLightAndDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme'**
  String get switchBetweenLightAndDarkTheme;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getHelpWhenNeeded.
  ///
  /// In en, this message translates to:
  /// **'Get help when you need it'**
  String get getHelpWhenNeeded;

  /// No description provided for @learnMoreAboutExpenseTracker.
  ///
  /// In en, this message translates to:
  /// **'Learn more about Xpensemate'**
  String get learnMoreAboutExpenseTracker;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logoutFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Logout from your account'**
  String get logoutFromAccount;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// No description provided for @expenseTracker.
  ///
  /// In en, this message translates to:
  /// **'Xpensemate'**
  String get expenseTracker;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 • Build 2024.1'**
  String get version;

  /// No description provided for @craftedWithLove.
  ///
  /// In en, this message translates to:
  /// **'Crafted with ❤️ for smarter expense tracking'**
  String get craftedWithLove;

  /// No description provided for @moto.
  ///
  /// In en, this message translates to:
  /// **'Track Smart, Spend Wise'**
  String get moto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @areYouSureYouWantToSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantToSignOut;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This amazing feature is coming soon!\nStay tuned for updates.'**
  String get comingSoonMessage;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @signOutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your account and need to sign in again to continue.'**
  String get signOutConfirmationMessage;

  /// No description provided for @signOutConfirmationButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmationButton;

  /// No description provided for @signOutConfirmationCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get signOutConfirmationCancel;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourBio.
  ///
  /// In en, this message translates to:
  /// **'Enter your bio'**
  String get enterYourBio;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @nameMustBeAtLeast4Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 4 characters'**
  String get nameMustBeAtLeast4Characters;

  /// No description provided for @phoneNumberMustBeAtLeast10Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get phoneNumberMustBeAtLeast10Digits;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to want to logout?'**
  String get logoutConfirmationMessage;

  /// No description provided for @seeDetail.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeDetail;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Message shown when opening camera for image capture
  ///
  /// In en, this message translates to:
  /// **'Opening camera...'**
  String get openingCamera;

  /// Message shown when opening gallery for image selection
  ///
  /// In en, this message translates to:
  /// **'Opening gallery...'**
  String get openingGallery;

  /// Message shown when processing selected image
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// Success message when image is selected and validated
  ///
  /// In en, this message translates to:
  /// **'Image selected successfully!'**
  String get imageSelectedSuccessfully;

  /// Info message when user cancels image selection
  ///
  /// In en, this message translates to:
  /// **'Image selection cancelled'**
  String get imageSelectionCancelled;

  /// Error message when image selection fails
  ///
  /// In en, this message translates to:
  /// **'Failed to select image. Please try again.'**
  String get imageSelectionFailed;

  /// Error message when selected image file size exceeds the maximum limit
  ///
  /// In en, this message translates to:
  /// **'File size ({size} MB) exceeds the limit of 10 MB. Please choose a smaller image.'**
  String fileSizeExceeded(String size);

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRationale.
  ///
  /// In en, this message translates to:
  /// **'We need this permission to provide you with the best experience.'**
  String get permissionRationale;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get proceed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable this permission from settings to use this feature.'**
  String get permissionDeniedMessage;

  /// No description provided for @cameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We need camera access to take photos.'**
  String get cameraPermissionMessage;

  /// No description provided for @galleryPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We need gallery access to choose photos.'**
  String get galleryPermissionMessage;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Enter your bio'**
  String get personalInformation;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// Phone number min length message
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least {min} digits'**
  String phoneNumberMinLength(int min);

  /// No description provided for @phoneNumberTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number is not valid (too short)'**
  String get phoneNumberTooShort;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// Name min length message
  ///
  /// In en, this message translates to:
  /// **'Name must be at least {min} characters'**
  String nameMinLength(int min);

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @noCountryFound.
  ///
  /// In en, this message translates to:
  /// **'No country found'**
  String get noCountryFound;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get tellUsAboutYourself;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get errorSavingProfile;

  /// No description provided for @errorWhileOpeningUrl.
  ///
  /// In en, this message translates to:
  /// **'Link is not valid'**
  String get errorWhileOpeningUrl;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Title for the weekly financial overview section
  ///
  /// In en, this message translates to:
  /// **'Weekly Financial Overview'**
  String get weeklyFinancialOverview;

  /// Title for weekly insights section
  ///
  /// In en, this message translates to:
  /// **'Weekly Insights'**
  String get weeklyInsights;

  /// Label for the day with highest spending
  ///
  /// In en, this message translates to:
  /// **'Highest Day'**
  String get highestDay;

  /// Label for the day with lowest spending
  ///
  /// In en, this message translates to:
  /// **'Lowest Day'**
  String get lowestDay;

  /// Label for daily average spending
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// Subtitle for daily average calculation
  ///
  /// In en, this message translates to:
  /// **'across 7 days'**
  String get acrossSevenDays;

  /// Label for remaining budget balance
  ///
  /// In en, this message translates to:
  /// **'Balance Remaining'**
  String get balanceRemaining;

  /// Label for total expenses
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// Title for daily spending bar chart
  ///
  /// In en, this message translates to:
  /// **'Daily Spending Pattern'**
  String get dailySpendingPattern;

  /// Time period label for current week
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get thisWeek;

  /// Title for monthly insight section
  ///
  /// In en, this message translates to:
  /// **'Monthly Insight'**
  String get monthlyInsight;

  /// Title for quarterly insight section
  ///
  /// In en, this message translates to:
  /// **'Quarterly Insight'**
  String get quarterInsight;

  /// Title for yearly insight section
  ///
  /// In en, this message translates to:
  /// **'Yearly Insight'**
  String get yearlyInsight;

  /// Title for spending trend line chart
  ///
  /// In en, this message translates to:
  /// **'Spending Trend'**
  String get spendingTrend;

  /// Loading message for dashboard data
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard data...'**
  String get loadingDashboardData;

  /// Error message when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// Button text to retry failed operation
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Message shown when no expense data is available
  ///
  /// In en, this message translates to:
  /// **'Start tracking your expenses to see insights'**
  String get startTrackingExpenses;

  /// Message when no spending data is available for charts
  ///
  /// In en, this message translates to:
  /// **'No spending data'**
  String get noSpendingData;

  /// Message when no trend data is available
  ///
  /// In en, this message translates to:
  /// **'No trend data'**
  String get noTrendData;

  /// No description provided for @of12.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get of12;

  /// Budget label
  ///
  /// In en, this message translates to:
  /// **'Budget Goals'**
  String get budget;

  /// Expenses label
  ///
  /// In en, this message translates to:
  /// **'expenses'**
  String get expenses;

  /// Expenses label
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expense;

  /// Archive button label
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Label for cumulative values in charts
  ///
  /// In en, this message translates to:
  /// **'cumulative'**
  String get cumulative;

  /// Morning greeting shown before noon
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Afternoon greeting shown between noon and evening
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Evening greeting shown after 5 PM
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Subtitle shown below greeting in dashboard
  ///
  /// In en, this message translates to:
  /// **'Here\'s your financial overview'**
  String get financialOverviewSubtitle;

  /// Label for total balance in financial overview
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// Comparison text for financial metrics
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get vsLastWeek;

  /// Label for available balance
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Label for amount spent in current week
  ///
  /// In en, this message translates to:
  /// **'Spent This Week'**
  String get spentThisWeek;

  /// Title for active budgets section
  ///
  /// In en, this message translates to:
  /// **'Active Budgets'**
  String get activeBudgets;

  /// Message when no active budgets are available
  ///
  /// In en, this message translates to:
  /// **'No active budgets'**
  String get noBudgetsActive;

  /// Button text to create a new budget
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// Label for budget progress
  ///
  /// In en, this message translates to:
  /// **'Budget Progress'**
  String get budgetProgress;

  /// Label for remaining budget amount
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// Label for spent amount
  ///
  /// In en, this message translates to:
  /// **'spent'**
  String get spent;

  /// High priority label
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highPriority;

  /// Medium priority label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumPriority;

  /// Low priority label
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowPriority;

  /// Budget status when on track
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// Budget status when over budget
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// Budget status when near the limit
  ///
  /// In en, this message translates to:
  /// **'Near Limit'**
  String get nearLimit;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Expense description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Expense amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Expense category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Expense date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Expense time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Expense location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Expense payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Expense details label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Invalid amount error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// Product Analytics
  ///
  /// In en, this message translates to:
  /// **'Product Analytics'**
  String get productAnalytic;

  /// No description provided for @fieldTooShort.
  ///
  /// In en, this message translates to:
  /// **'This field is too short (minimum 2 characters)'**
  String get fieldTooShort;

  /// No description provided for @fieldTooLong.
  ///
  /// In en, this message translates to:
  /// **'This field is too long (maximum 100 characters)'**
  String get fieldTooLong;

  /// Title for the budget overview section
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Subtitle for the budget statistics section
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get budgetStatistics;

  /// Subtitle for the budget statistics section with period
  ///
  /// In en, this message translates to:
  /// **' Statistics'**
  String periodBudgetStatistics(String period);

  /// Label for total budget goals count
  ///
  /// In en, this message translates to:
  /// **'Total Goals'**
  String get totalGoals;

  /// Label for active budget goals count
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Label for achieved budget goals count
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// Label for failed and terminated budget goals count
  ///
  /// In en, this message translates to:
  /// **'Failed/Terminated'**
  String get failedTerminated;

  /// Subtitle for failed/terminated goals card
  ///
  /// In en, this message translates to:
  /// **'Goals not completed'**
  String get goalsNotCompleted;

  /// Label for total budgeted amount
  ///
  /// In en, this message translates to:
  /// **'Total Budgeted'**
  String get totalBudgeted;

  /// Subtitle for total budgeted amount card
  ///
  /// In en, this message translates to:
  /// **'Total amount allocated for active goals'**
  String get totalAmountAllocated;

  /// Label for average progress percentage
  ///
  /// In en, this message translates to:
  /// **'Avg. Progress'**
  String get avgProgress;

  /// Subtitle for average progress card
  ///
  /// In en, this message translates to:
  /// **'Average progress across all goals'**
  String get averageProgressGoals;

  /// Label for closest deadline date
  ///
  /// In en, this message translates to:
  /// **'Closest Deadline'**
  String get closestDeadline;

  /// Subtitle for closest deadline card
  ///
  /// In en, this message translates to:
  /// **'Next upcoming deadline'**
  String get nextUpcomingDeadline;

  /// Label for overdue goals count
  ///
  /// In en, this message translates to:
  /// **'Overdue Goals'**
  String get overdueGoals;

  /// Subtitle for overdue goals card
  ///
  /// In en, this message translates to:
  /// **'Goals past their deadline'**
  String get goalsPastDeadline;

  /// Text shown when there are no deadlines
  ///
  /// In en, this message translates to:
  /// **'No deadlines'**
  String get noDeadlines;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
