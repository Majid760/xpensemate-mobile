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
  String get expenseLoaded => 'All expenses loaded successfully!';

  @override
  String get expenseDeleted => 'Expense deleted successfully!';

  @override
  String get expenseUpdated => 'Expense updated successfully!';

  @override
  String get expenseCreated => 'Expense created successfully!';

  @override
  String get expenseFailed => 'Expense failed to load!';

  @override
  String get expenseDeletedFailed => 'Expense failed to delete!';

  @override
  String get expenseUpdatedFailed => 'Expense failed to update!';

  @override
  String get expenseCreatedFailed => 'Expense failed to create!';

  @override
  String get currencySymbol => '\$';

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
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSuccess =>
      'Password reset email sent. Please check your inbox.';

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
  String get verificationInstructions =>
      'Please check your email for the verification link.';

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
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get confirmPasswordRequired => 'Confirm Password is required';

  @override
  String get registerSuccess => 'Account created successfully!';

  @override
  String get verifyEmail =>
      'We have sent a verification email to your email address. Please check your inbox.';

  @override
  String get verifyEmailSuccess => 'Email verification sent successfully!';

  @override
  String get verifyEmailFailed =>
      'Email verification failed. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorTimeout => 'Request timeout. Please try again.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get budgetGoalsLoading => 'Loading...';

  @override
  String get budgetGoalsRetry => 'Retry';

  @override
  String get budgetGoalsError => 'An error occurred';

  @override
  String get budgetGoalsEmptyTitle => 'No budget goals yet';

  @override
  String get budgetGoalsEmptySubtitle => 'Create a budget goal';

  @override
  String get budgetGoalsAllLoaded => 'All budget goals loaded';

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
  String get selectCurrency => 'Select Currency';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get average => 'Average';

  @override
  String get transactions => 'Transactions';

  @override
  String budgetGoalLabel(Object amount) {
    return 'Budget Goal: $amount';
  }

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
  String get appSettings => 'Customize app preferences';

  @override
  String get addWidgets => 'Add Widgets';

  @override
  String get addWidgetsDescription =>
      'Add widgets to your home screen to make it easier to access your most used features.';

  @override
  String get choosePreferredLanguage => 'Choose your preferred language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get switchBetweenLightAndDarkTheme =>
      'Switch between light and dark theme';

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
  String get completeYourProfile => 'Complete your profile';

  @override
  String get expenseTracker => 'Xpensemate';

  @override
  String get version => 'Version 1.0.0 • Build 2024.1';

  @override
  String get craftedWithLove => 'Crafted with ❤️ for smarter expense tracking';

  @override
  String get moto => 'Track Smart, Spend Wise';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get gotIt => 'Got it!';

  @override
  String get areYouSureYouWantToSignOut => 'Are you sure you want to sign out?';

  @override
  String get comingSoonMessage =>
      'This amazing feature is coming soon!\nStay tuned for updates.';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get signOutConfirmationMessage =>
      'You will be signed out of your account and need to sign in again to continue.';

  @override
  String get signOutConfirmationButton => 'Sign Out';

  @override
  String get signOutConfirmationCancel => 'Cancel';

  @override
  String get fullName => 'Full Name';

  @override
  String get gender => 'Gender';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get bio => 'Bio';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterYourBio => 'Enter your bio';

  @override
  String get selectDateOfBirth => 'Select date of birth';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get nameMustBeAtLeast4Characters =>
      'Name must be at least 4 characters';

  @override
  String get phoneNumberMustBeAtLeast10Digits =>
      'Phone number must be at least 10 digits';

  @override
  String get logoutConfirmationMessage => 'Are you sure to want to logout?';

  @override
  String get userSessionNotFound => 'User session not found';

  @override
  String get ageMinError => 'You must be at least 7 years old';

  @override
  String get ageMaxError => 'You cannot be more than 100 years old';

  @override
  String get dobRequired => 'Date of birth is required';

  @override
  String get seeDetail => 'See Detail';

  @override
  String get selectImage => 'Select Image';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get openingCamera => 'Opening camera...';

  @override
  String get openingGallery => 'Opening gallery...';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get imageSelectedSuccessfully => 'Image selected successfully!';

  @override
  String get imageSelectionCancelled => 'Image selection cancelled';

  @override
  String get imageSelectionFailed =>
      'Failed to select image. Please try again.';

  @override
  String fileSizeExceeded(String size) {
    return 'File size ($size MB) exceeds the limit of 10 MB. Please choose a smaller image.';
  }

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRationale =>
      'We need this permission to provide you with the best experience.';

  @override
  String get notNow => 'Not Now';

  @override
  String get proceed => 'Continue';

  @override
  String get openSettings => 'Settings';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionDeniedMessage =>
      'Please enable this permission from settings to use this feature.';

  @override
  String get cameraPermissionMessage => 'We need camera access to take photos.';

  @override
  String get galleryPermissionMessage =>
      'We need gallery access to choose photos.';

  @override
  String get personalInformation => 'Enter your bio';

  @override
  String get day => 'Day';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String phoneNumberMinLength(int min) {
    return 'Phone number must be at least $min digits';
  }

  @override
  String get phoneNumberTooShort => 'Phone number is not valid (too short)';

  @override
  String get selectGender => 'Select Gender';

  @override
  String nameMinLength(int min) {
    return 'Name must be at least $min characters';
  }

  @override
  String get searchCountry => 'Search country';

  @override
  String get noCountryFound => 'No country found';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself...';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get saving => 'Saving...';

  @override
  String get errorSavingProfile => 'Error saving profile';

  @override
  String get errorWhileOpeningUrl => 'Link is not valid';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get weeklyFinancialOverview => 'Weekly Financial Overview';

  @override
  String get weeklyInsights => 'Weekly Financial Overview';

  @override
  String get highestDay => 'Highest Day';

  @override
  String get lowestDay => 'Lowest Day';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get acrossSevenDays => 'across 7 days';

  @override
  String get balanceRemaining => 'Balance Remaining';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get dailySpendingPattern => 'Daily Spending Pattern';

  @override
  String get thisWeek => 'this week';

  @override
  String get monthlyInsight => 'Monthly Insights';

  @override
  String get quarterlyInsights => 'Quarterly Insights';

  @override
  String get yearlyInsights => 'Yearly Insights';

  @override
  String get spendingTrend => 'Spending Trend';

  @override
  String get loadingDashboardData => 'Loading dashboard data...';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get startTrackingExpenses =>
      'Start tracking your expenses to see insights';

  @override
  String get noSpendingData => 'No spending data';

  @override
  String get noTrendData => 'No trend data';

  @override
  String get of12 => 'of';

  @override
  String get budget => 'Budget';

  @override
  String get expenses => 'expenses';

  @override
  String get expense => 'Expenses';

  @override
  String get archive => 'Archive';

  @override
  String get share => 'Share';

  @override
  String get cumulative => 'cumulative';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get financialOverviewSubtitle => 'Here\'s your financial overview';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get vsLastWeek => 'vs last week';

  @override
  String get available => 'Available';

  @override
  String get spentThisWeek => 'Spent This Week';

  @override
  String get moderate => 'Moderate';

  @override
  String get mediumPriorityAbbr => 'Med';

  @override
  String get activeBudgets => 'Active Budgets';

  @override
  String get noBudgetsActive => 'No goals';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get budgetProgress => 'Budget Progress';

  @override
  String get remaining => 'Remaining';

  @override
  String get spent => 'Spent';

  @override
  String get highPriority => 'High';

  @override
  String get mediumPriority => 'Medium';

  @override
  String get lowPriority => 'Low';

  @override
  String get onTrack => 'On Track';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get nearLimit => 'Near Limit';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get location => 'Location';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get details => 'Details';

  @override
  String get invalidAmount => 'Please enter a valid amount';

  @override
  String get productAnalytic => 'Product Analytics';

  @override
  String get fieldTooShort => 'This field is too short (minimum 2 characters)';

  @override
  String get fieldTooLong => 'This field is too long (maximum 100 characters)';

  @override
  String get overview => 'Overview';

  @override
  String get budgetStatistics => 'Budget Statistics';

  @override
  String periodBudgetStatistics(String period) {
    return '$period Budget Statistics';
  }

  @override
  String get totalGoals => 'Total Goals';

  @override
  String get active => 'Active';

  @override
  String get achieved => 'Achieved';

  @override
  String get failedTerminated => 'Failed/Terminated';

  @override
  String get goalsNotCompleted => 'Goals not completed';

  @override
  String get totalBudgeted => 'Total Budgeted';

  @override
  String get totalAmountAllocated => 'Total amount allocated for active goals';

  @override
  String get avgProgress => 'Avg. Progress';

  @override
  String get averageProgressGoals => 'Average progress across all goals';

  @override
  String get closestDeadline => 'Closest Deadline';

  @override
  String get nextUpcomingDeadline => 'Next upcoming deadline';

  @override
  String get overdueGoals => 'Overdue Goals';

  @override
  String get goalsPastDeadline => 'Goals past their deadline';

  @override
  String get noDeadlines => 'No deadlines';

  @override
  String get onboardingTitle1 => 'Track Your Expenses';

  @override
  String get onboardingDesc1 =>
      'Keep track of every penny you spend and manage your finances with ease.';

  @override
  String get onboardingTitle2 => 'Set Smart Budgets';

  @override
  String get onboardingDesc2 =>
      'Create budgets for different categories and stay on track with your financial goals.';

  @override
  String get onboardingTitle3 => 'Gain Financial Insights';

  @override
  String get onboardingDesc3 =>
      'Visualize your spending habits with detailed charts and reports.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get premiumTitle => 'Upgrade to Premium';

  @override
  String get premiumSubtitle => 'Unlock the full potential of Xpensemate';

  @override
  String get featureUnlimitedBudgets => 'Unlimited Budgets';

  @override
  String get featureAdvancedAnalytics => 'Advanced Analytics';

  @override
  String get featureDataExport => 'Data Export (PDF/CSV)';

  @override
  String get featureCloudSync => 'Cloud Sync & Backup';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get bestValue => 'Best Value';

  @override
  String get payment => 'Payment';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get addCustomCategory => '+ Add Custom Category';

  @override
  String get noBudgetGoal => 'No Budget Goal';

  @override
  String get pleaseFillRequired => 'Please fill out all required fields';

  @override
  String get failedToLoadBudgets => 'Failed to load budgets';

  @override
  String get noExpensesFound => 'No Expense found!';

  @override
  String get errorLoadingExpenses => 'Error while loading expenses!';

  @override
  String get noMoreExpenses => 'No more expenses!';

  @override
  String get streak => 'Streak';

  @override
  String get spendingVelocity => 'Spending Velocity';

  @override
  String get trackingStreak => 'Tracking Streak';

  @override
  String get consecutiveDays => 'Consecutive days';

  @override
  String get totalSpentSubtitle => 'Total spent in period';

  @override
  String get dailyAverageSubtitle => 'Daily average in period';

  @override
  String get insights => 'Insights';

  @override
  String get doingGreat => 'You\'re doing great!';

  @override
  String get budgetExceeded => 'Budget exceeded';

  @override
  String get mostActiveGoal => 'Most Active Goal';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get closeSearch => 'Close search';

  @override
  String daysUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days used',
      one: '1 day used',
    );
    return '$_temp0';
  }

  @override
  String get permanentlyDenied => 'Permanently Denied';

  @override
  String get disablePermissionManual =>
      'Please disable this permission manually in Settings';

  @override
  String get photos => 'Photos';

  @override
  String get locationInUse => 'Location (In Use)';

  @override
  String get mediaLibrary => 'Media Library';

  @override
  String get currency => 'Currency';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get useFingerprintOrFaceId => 'Use fingerprint or Face ID to unlock';

  @override
  String get appPermissions => 'App Permissions';

  @override
  String get appPermissionsDesc => 'Manage app permissions';

  @override
  String get transactionReminders => 'Transaction Reminders';

  @override
  String get transactionRemindersDesc =>
      'Get reminded to log your transactions';

  @override
  String get budgetAlerts => 'Budget Alerts';

  @override
  String get budgetAlertsDesc => 'Get notified when approaching budget limits';

  @override
  String get receiveNotificationsDesc => 'Receive push notifications';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDesc => 'Export your data to CSV or PDF';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataDesc => 'Import data from a file';

  @override
  String get budgetAndCategories => 'Budget & Categories';

  @override
  String get budgetPeriod => 'Budget Period';

  @override
  String get setBudgetCycleDesc => 'Set your budget cycle period';

  @override
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get manageRecurringDesc => 'Manage your recurring transactions';

  @override
  String get privacyPolicyDesc => 'Read our privacy policy';

  @override
  String get termsOfServiceDesc => 'Read our terms of service';

  @override
  String get appVersion => 'App Version';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDesc => 'Permanently delete all your data';

  @override
  String get storage => 'Storage';

  @override
  String get allowed => 'Allowed';

  @override
  String get denied => 'Denied';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get readTermsAndConditions => 'Read our terms and conditions';

  @override
  String get lightThemeDesc => 'Always use light theme';

  @override
  String get darkThemeDesc => 'Always use dark theme';

  @override
  String get systemThemeDesc => 'Follow system settings';

  @override
  String get currencyUSD => 'US Dollar';

  @override
  String get currencyPKR => 'Pakistani Rupee';

  @override
  String get currencyEUR => 'Euro';

  @override
  String get currencyGBP => 'British Pound';

  @override
  String get currencyJPY => 'Japanese Yen';

  @override
  String get currencyAUD => 'Australian Dollar';

  @override
  String get currencyCAD => 'Canadian Dollar';

  @override
  String get currencyCHF => 'Swiss Franc';

  @override
  String get currencyCNY => 'Chinese Yuan';

  @override
  String get currencyINR => 'Indian Rupee';
}
