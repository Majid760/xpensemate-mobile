/// Centralized locale keys for type-safe access to translations
/// This provides compile-time safety and better IDE support
class LocaleKeys {
  // Private constructor to prevent instantiation
  LocaleKeys._();

  // ===========================================
  // NAVIGATION & APP STRUCTURE
  // ===========================================
  static const String appTitle = 'appTitle';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String about = 'about';

  // ===========================================
  // COMMON ACTIONS
  // ===========================================
  static const String save = 'save';
  static const String cancel = 'cancel';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String add = 'add';
  static const String confirm = 'confirm';
  static const String retry = 'retry';
  static const String close = 'close';
  static const String next = 'next';
  static const String back = 'back';
  static const String done = 'done';
  static const String loading = 'loading';
  static const String refresh = 'refresh';
  static const String submit = 'submit';
  static const String apply = 'apply';
  static const String reset = 'reset';
  static const String clear = 'clear';
  static const String update = 'update';
  static const String create = 'create';
  static const String remove = 'remove';
  static const String copy = 'copy';
  static const String paste = 'paste';
  static const String cut = 'cut';
  static const String share = 'share';
  static const String download = 'download';
  static const String upload = 'upload';
  static const String import = 'import';
  static const String export = 'export';

  // ===========================================
  // AUTHENTICATION & USER MANAGEMENT
  // ===========================================
  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'register';
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String signOut = 'signOut';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String forgotPassword = 'forgotPassword';
  static const String welcomeBack = 'welcomeBack';
  static const String createAccount = 'createAccount';
  static const String resetPassword = 'resetPassword';
  static const String changePassword = 'changePassword';
  static const String currentPassword = 'currentPassword';
  static const String newPassword = 'newPassword';
  static const String username = 'username';
  static const String fullName = 'fullName';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String phoneNumber = 'phoneNumber';
  static const String dateOfBirth = 'dateOfBirth';
  static const String gender = 'gender';
  static const String address = 'address';
  static const String city = 'city';
  static const String country = 'country';
  static const String zipCode = 'zipCode';

  // ===========================================
  // VALIDATION MESSAGES
  // ===========================================
  static const String fieldRequired = 'fieldRequired';
  static const String invalidEmail = 'invalidEmail';
  static const String passwordTooShort = 'passwordTooShort';
  static const String passwordsDoNotMatch = 'passwordsDoNotMatch';
  static const String invalidPhoneNumber = 'invalidPhoneNumber';
  static const String invalidDate = 'invalidDate';
  static const String invalidUrl = 'invalidUrl';
  static const String fieldTooShort = 'fieldTooShort';
  static const String fieldTooLong = 'fieldTooLong';
  static const String invalidFormat = 'invalidFormat';
  static const String mustBeNumber = 'mustBeNumber';
  static const String mustBePositive = 'mustBePositive';
  static const String outOfRange = 'outOfRange';

  // ===========================================
  // ERROR MESSAGES
  // ===========================================
  static const String errorGeneric = 'errorGeneric';
  static const String errorNetwork = 'errorNetwork';
  static const String errorTimeout = 'errorTimeout';
  static const String errorNotFound = 'errorNotFound';
  static const String errorUnauthorized = 'errorUnauthorized';
  static const String errorForbidden = 'errorForbidden';
  static const String errorServerError = 'errorServerError';
  static const String errorBadRequest = 'errorBadRequest';
  static const String errorConnectionFailed = 'errorConnectionFailed';
  static const String errorInvalidCredentials = 'errorInvalidCredentials';
  static const String errorAccountLocked = 'errorAccountLocked';
  static const String errorEmailAlreadyExists = 'errorEmailAlreadyExists';
  static const String errorFileNotFound = 'errorFileNotFound';
  static const String errorFileTooBig = 'errorFileTooBig';
  static const String errorInvalidFileType = 'errorInvalidFileType';

  // ===========================================
  // SUCCESS MESSAGES
  // ===========================================
  static const String saveSuccess = 'saveSuccess';
  static const String deleteSuccess = 'deleteSuccess';
  static const String updateSuccess = 'updateSuccess';
  static const String createSuccess = 'createSuccess';
  static const String uploadSuccess = 'uploadSuccess';
  static const String downloadSuccess = 'downloadSuccess';
  static const String emailSentSuccess = 'emailSentSuccess';
  static const String passwordChangedSuccess = 'passwordChangedSuccess';
  static const String profileUpdatedSuccess = 'profileUpdatedSuccess';
  static const String accountCreatedSuccess = 'accountCreatedSuccess';
  static const String loginSuccess = 'loginSuccess';
  static const String logoutSuccess = 'logoutSuccess';

  // ===========================================
  // PLACEHOLDERS & EMPTY STATES
  // ===========================================
  static const String searchPlaceholder = 'searchPlaceholder';
  static const String noDataAvailable = 'noDataAvailable';
  static const String emptyListMessage = 'emptyListMessage';
  static const String noResultsFound = 'noResultsFound';
  static const String typeToSearch = 'typeToSearch';
  static const String enterText = 'enterText';
  static const String selectOption = 'selectOption';
  static const String chooseFile = 'chooseFile';
  static const String dragDropFile = 'dragDropFile';
  static const String noNotifications = 'noNotifications';
  static const String noMessages = 'noMessages';
  static const String emptyCart = 'emptyCart';
  static const String noFavorites = 'noFavorites';

  // ===========================================
  // DIALOG & CONFIRMATION MESSAGES
  // ===========================================
  static const String confirmDelete = 'confirmDelete';
  static const String confirmLogout = 'confirmLogout';
  static const String deleteWarning = 'deleteWarning';
  static const String unsavedChanges = 'unsavedChanges';
  static const String discardChanges = 'discardChanges';
  static const String areYouSure = 'areYouSure';
  static const String cannotBeUndone = 'cannotBeUndone';
  static const String confirmAction = 'confirmAction';
  static const String proceedAnyway = 'proceedAnyway';
  static const String saveChangesFirst = 'saveChangesFirst';

  // ===========================================
  // STATUS & STATE MESSAGES
  // ===========================================
  static const String online = 'online';
  static const String offline = 'offline';
  static const String connecting = 'connecting';
  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String enabled = 'enabled';
  static const String disabled = 'disabled';
  static const String available = 'available';
  static const String unavailable = 'unavailable';
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String completed = 'completed';
  static const String inProgress = 'inProgress';
  static const String cancelled = 'cancelled';
  static const String expired = 'expired';

  // ===========================================
  // PARAMETRIZED MESSAGES
  // ===========================================
  static const String welcomeUser = 'welcomeUser';
  static const String itemCount = 'itemCount';
  static const String lastUpdated = 'lastUpdated';
  static const String createdAt = 'createdAt';
  static const String modifiedAt = 'modifiedAt';
  static const String timeAgo = 'timeAgo';
  static const String itemsSelected = 'itemsSelected';
  static const String filesUploaded = 'filesUploaded';
  static const String charactersRemaining = 'charactersRemaining';
  static const String resultsFound = 'resultsFound';
  static const String pageNumber = 'pageNumber';

  // ===========================================
  // THEME & APPEARANCE
  // ===========================================
  static const String themeMode = 'themeMode';
  static const String lightTheme = 'lightTheme';
  static const String darkTheme = 'darkTheme';
  static const String systemTheme = 'systemTheme';
  static const String appearance = 'appearance';
  static const String brightness = 'brightness';
  static const String colorScheme = 'colorScheme';
  static const String fontSize = 'fontSize';
  static const String fontFamily = 'fontFamily';

  // ===========================================
  // LANGUAGE & LOCALIZATION
  // ===========================================
  static const String language = 'language';
  static const String selectLanguage = 'selectLanguage';
  static const String languageChanged = 'languageChanged';
  static const String currentLanguage = 'currentLanguage';
  static const String changeLanguage = 'changeLanguage';
  static const String locale = 'locale';
  static const String region = 'region';
  static const String timeZone = 'timeZone';
  static const String dateFormat = 'dateFormat';
  static const String timeFormat = 'timeFormat';
  static const String currency = 'currency';

  // ===========================================
  // ACCESSIBILITY
  // ===========================================
  static const String accessibility = 'accessibility';
  static const String screenReader = 'screenReader';
  static const String highContrast = 'highContrast';
  static const String largeText = 'largeText';
  static const String reduceMotion = 'reduceMotion';
  static const String voiceOver = 'voiceOver';
  static const String talkBack = 'talkBack';

  // ===========================================
  // NOTIFICATIONS & ALERTS
  // ===========================================
  static const String notifications = 'notifications';
  static const String alerts = 'alerts';
  static const String pushNotifications = 'pushNotifications';
  static const String emailNotifications = 'emailNotifications';
  static const String smsNotifications = 'smsNotifications';
  static const String soundEnabled = 'soundEnabled';
  static const String vibrationEnabled = 'vibrationEnabled';
  static const String notificationSettings = 'notificationSettings';

  // ===========================================
  // PRIVACY & SECURITY
  // ===========================================
  static const String privacy = 'privacy';
  static const String security = 'security';
  static const String permissions = 'permissions';
  static const String dataProtection = 'dataProtection';
  static const String cookiePolicy = 'cookiePolicy';
  static const String termsOfService = 'termsOfService';
  static const String privacyPolicy = 'privacyPolicy';
  static const String twoFactorAuth = 'twoFactorAuth';
  static const String biometricAuth = 'biometricAuth';
  static const String faceLock = 'faceLock';
  static const String fingerprint = 'fingerprint';

  // ===========================================
  // TIME & DATE
  // ===========================================
  static const String today = 'today';
  static const String yesterday = 'yesterday';
  static const String tomorrow = 'tomorrow';
  static const String thisWeek = 'thisWeek';
  static const String lastWeek = 'lastWeek';
  static const String nextWeek = 'nextWeek';
  static const String thisMonth = 'thisMonth';
  static const String lastMonth = 'lastMonth';
  static const String nextMonth = 'nextMonth';
  static const String thisYear = 'thisYear';
  static const String lastYear = 'lastYear';
  static const String nextYear = 'nextYear';
  static const String now = 'now';
  static const String soon = 'soon';
  static const String later = 'later';
  static const String never = 'never';
  static const String always = 'always';

  // ===========================================
  // NUMBERS & QUANTITIES
  // ===========================================
  static const String zero = 'zero';
  static const String one = 'one';
  static const String two = 'two';
  static const String few = 'few';
  static const String many = 'many';
  static const String all = 'all';
  static const String none = 'none';
  static const String some = 'some';
  static const String more = 'more';
  static const String less = 'less';
  static const String total = 'total';
  static const String count = 'count';
  static const String amount = 'amount';
  static const String quantity = 'quantity';
  static const String percentage = 'percentage';

  // ===========================================
  // FILE & MEDIA
  // ===========================================
  static const String file = 'file';
  static const String files = 'files';
  static const String image = 'image';
  static const String images = 'images';
  static const String video = 'video';
  static const String videos = 'videos';
  static const String audio = 'audio';
  static const String document = 'document';
  static const String documents = 'documents';
  static const String folder = 'folder';
  static const String folders = 'folders';
  static const String gallery = 'gallery';
  static const String camera = 'camera';
  static const String microphone = 'microphone';
  static const String storage = 'storage';

  // ===========================================
  // UTILITY METHODS
  // ===========================================
  
  /// Get all locale keys as a list
  static List<String> get allKeys => [
    // Navigation
    appTitle, home, profile, settings, about,
    
    // Actions
    save, cancel, delete, edit, add, confirm, retry, close, next, back, done, loading,
    refresh, submit, apply, reset, clear, update, create, remove, copy, paste, cut,
    share, download, upload, import, export,
    
    // Authentication
    login, logout, register, signIn, signUp, signOut, email, password, confirmPassword,
    forgotPassword, welcomeBack, createAccount, resetPassword, changePassword,
    currentPassword, newPassword, username, fullName, firstName, lastName,
    phoneNumber, dateOfBirth, gender, address, city, country, zipCode,
    
    // Validation
    fieldRequired, invalidEmail, passwordTooShort, passwordsDoNotMatch,
    invalidPhoneNumber, invalidDate, invalidUrl, fieldTooShort, fieldTooLong,
    invalidFormat, mustBeNumber, mustBePositive, outOfRange,
    
    // Errors
    errorGeneric, errorNetwork, errorTimeout, errorNotFound, errorUnauthorized,
    errorForbidden, errorServerError, errorBadRequest, errorConnectionFailed,
    errorInvalidCredentials, errorAccountLocked, errorEmailAlreadyExists,
    errorFileNotFound, errorFileTooBig, errorInvalidFileType,
    
    // Success
    saveSuccess, deleteSuccess, updateSuccess, createSuccess, uploadSuccess,
    downloadSuccess, emailSentSuccess, passwordChangedSuccess,
    profileUpdatedSuccess, accountCreatedSuccess, loginSuccess, logoutSuccess,
    
    // Placeholders
    searchPlaceholder, noDataAvailable, emptyListMessage, noResultsFound,
    typeToSearch, enterText, selectOption, chooseFile, dragDropFile,
    noNotifications, noMessages, emptyCart, noFavorites,
    
    // Confirmations
    confirmDelete, confirmLogout, deleteWarning, unsavedChanges, discardChanges,
    areYouSure, cannotBeUndone, confirmAction, proceedAnyway, saveChangesFirst,
    
    // Status
    online, offline, connecting, connected, disconnected, active, inactive,
    enabled, disabled, available, unavailable, pending, approved, rejected,
    completed, inProgress, cancelled, expired,
    
    // Parametrized
    welcomeUser, itemCount, lastUpdated, createdAt, modifiedAt, timeAgo,
    itemsSelected, filesUploaded, charactersRemaining, resultsFound, pageNumber,
    
    // Theme
    themeMode, lightTheme, darkTheme, systemTheme, appearance, brightness,
    colorScheme, fontSize, fontFamily,
    
    // Language
    language, selectLanguage, languageChanged, currentLanguage, changeLanguage,
    locale, region, timeZone, dateFormat, timeFormat, currency,
    
    // Accessibility
    accessibility, screenReader, highContrast, largeText, reduceMotion,
    voiceOver, talkBack,
    
    // Notifications
    notifications, alerts, pushNotifications, emailNotifications, smsNotifications,
    soundEnabled, vibrationEnabled, notificationSettings,
    
    // Privacy
    privacy, security, permissions, dataProtection, cookiePolicy, termsOfService,
    privacyPolicy, twoFactorAuth, biometricAuth, faceLock, fingerprint,
    
    // Time
    today, yesterday, tomorrow, thisWeek, lastWeek, nextWeek, thisMonth,
    lastMonth, nextMonth, thisYear, lastYear, nextYear, now, soon, later,
    never, always,
    
    // Numbers
    zero, one, two, few, many, all, none, some, more, less, total, count,
    amount, quantity, percentage,
    
    // Media
    file, files, image, images, video, videos, audio, document, documents,
    folder, folders, gallery, camera, microphone, storage,
  ];
  
  /// Check if a key exists
  static bool containsKey(String key) => allKeys.contains(key);
  
  /// Get keys by category
  static List<String> get navigationKeys => [appTitle, home, profile, settings, about];
  
  static List<String> get actionKeys => [
    save, cancel, delete, edit, add, confirm, retry, close, next, back, done, loading,
  ];
  
  static List<String> get authKeys => [
    login, logout, register, email, password, confirmPassword, forgotPassword,
    welcomeBack, createAccount,
  ];
  
  static List<String> get validationKeys => [
    fieldRequired, invalidEmail, passwordTooShort, passwordsDoNotMatch,
  ];
  
  static List<String> get errorKeys => [
    errorGeneric, errorNetwork, errorTimeout, errorNotFound,
  ];
  
  static List<String> get successKeys => [
    saveSuccess, deleteSuccess, updateSuccess,
  ];
  
  static List<String> get themeKeys => [
    themeMode, lightTheme, darkTheme, systemTheme,
  ];
  
  static List<String> get languageKeys => [
    language, selectLanguage, languageChanged,
  ];
}

/// Extension to provide type-safe access to locale keys
extension LocaleKeysExtension on String {
  /// Check if this string is a valid locale key
  bool get isValidLocaleKey => LocaleKeys.containsKey(this);
  
  /// Get the category of this locale key
  String? get localeKeyCategory {
    if (LocaleKeys.navigationKeys.contains(this)) return 'Navigation';
    if (LocaleKeys.actionKeys.contains(this)) return 'Actions';
    if (LocaleKeys.authKeys.contains(this)) return 'Authentication';
    if (LocaleKeys.validationKeys.contains(this)) return 'Validation';
    if (LocaleKeys.errorKeys.contains(this)) return 'Errors';
    if (LocaleKeys.successKeys.contains(this)) return 'Success';
    if (LocaleKeys.themeKeys.contains(this)) return 'Theme';
    if (LocaleKeys.languageKeys.contains(this)) return 'Language';
    return null;
  }
}