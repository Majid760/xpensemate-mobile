/// Network configuration – infrastructure constants only.
/// Do **not** import this in domain or presentation code.
class NetworkConfigs {
  // ------------------------------------------------------------------
  //  Environment – switch via dart-define or flavor
  // ------------------------------------------------------------------
  static const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static String get baseUrl => switch (_env) {
        'prod' => 'http://192.168.15.148:5001/api/v1',
        'stg' => 'http://192.168.15.148:5001/api/v1',
        _ => 'http://192.168.0.105:5001/api/v1', // dev
      };

  // ------------------------------------------------------------------
  //  Auth & Global headers
  // ------------------------------------------------------------------
  static const String apiToken =
      String.fromEnvironment('API_TOKEN'); // empty in dev
  static const String apiKey = '337de965aa1699e2f780c62520e1d695';
  static const String googleAuthClientId =
      '803273612959-eqvf0ftg1hc1m9ba34mpk0ku7i351313.apps.googleusercontent.com';

  // ------------------------------------------------------------------
  //  End-points (relative to baseUrl)
  // ------------------------------------------------------------------
  static const String _auth = '/auth'; // ✅

  static const String register = '$_auth/register';
  static const String login = '$_auth/login';
  static const String loginWithGoogle = '$_auth/google-oauth';
  static const String forgotPassword = '$_auth/forgot-password';
  static const String resetPassword = '$_auth/reset-password'; // + /:token
  static const String refreshToken = '$_auth/refresh-token';
  static const String logout = '$_auth/logout';
  static const String sendVerificationEmail = '$_auth/resend-verification';

  static const String verifyEmail = '/verify-email'; // ✅
  static const String currentUser = '/me'; // ✅
  static const String profile = '/profile'; // base profile path if needed
  // updating/setting routes
  static const String updateProfile = '/settings/update-user';
  static const String updateProfilePhoto = '/settings/upload-profile';

  // dashboard endpoints
  static const String weeklyStats = '/expenses/weekly-stats';
  static const String budgetGoals = '/dashboard/budget-goals';
  static const String budgetGoalsStats = 'dashboard/budget-goals/stats';
  static const String expenseStats = '/dashboard/expense/stats';
  static const String activity = '/dashboard/activity';

  // expense endpoints
  static const String getAllExpenses = '/expenses';
  static const String createExpense = '/create-expense';
  // Get monthly expense summary
  static const String expenseCategories = '/expense/summary/monthly';
  // Update an expense
  static const String updateExpense = '/expense';
  static const String deleteExpense = '/expense';
  static const String getExpense = '/expense/:id';
  // expense insight endpoints
  static const String expenseInsight = '/expenses/stats';

  // budget goals endpoints
  // get budget goals bases on status
  static const String createBudget = '/create-budget-goal';
  // get all budget goals with pagination and filters
  static const String getBudgetGoals = '/budget-goals';
  // get budget goal by status
  static const String getBudgetGoalByStatus = '/budget-goals/status/:status';
  // Get monthly budget goals summary
  static const String getMonthlyBudgetGoalsSummary =
      '/budget-goal/summary/monthly';
  // Get a single budget goal by ID
  static const String getBudgetGoalById = '/budget-goal/:id';
  // Update a budget goal
  static const String updateBudgetGoal = '/budget-goal/';
// Delete a budget goal
  static const String deleteBudgetGoal = '/budget-goal/';
// Get a budget goal's progress
  static const String getBudgetGoalProgress = '/budget-goal/:id/progress';
  // Get goal stats by period
  static const String budgetInsight = '/budget/goal-insights';
  // Get all expense for specific budget
  static const String getAllExpensesOfBudgetGoal = '/budget-goal/';
  // budgets endpoints
  static const String budgets = '/budget-goals/status';
  // budgets by period endpoint
  static const String budgetsByPeriod = '/budget-by-period/';

  // ------------------------------------------------------------------
  //  Static Pages URLs
  // ------------------------------------------------------------------
  static String get aboutUrl => "http://192.168.15.84:3000/about";

  static String get privacyPolicyUrl => "http://192.168.15.84:3000/privacy";

  static String get termsAndConditionsUrl =>
      "http://192.168.15.84:3000/terms&conditions";

  static String get helpSupportUrl => "http://192.168.15.84:3000/help&support";

  // ------------------------------------------------------------------
  //  Timeouts & Retry
  // ------------------------------------------------------------------
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int maxRetries = 2;
}
