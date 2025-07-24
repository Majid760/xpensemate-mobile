/// Network configuration – infrastructure constants only.
/// Do **not** import this in domain or presentation code.
class NetworkConfigs {
  // ------------------------------------------------------------------
  //  Environment – switch via dart-define or flavor
  // ------------------------------------------------------------------
  static const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static String get baseUrl => switch (_env) {
        'prod' => 'http://localhost:5001/api/v1',
        'stg'  => 'http://localhost:5001/api/v1',
        _      => 'http://localhost:5001/api/v1', // dev
      };

  // ------------------------------------------------------------------
  //  Auth & Global headers
  // ------------------------------------------------------------------
  static const String apiToken  = String.fromEnvironment('API_TOKEN');  // empty in dev
  static const String apiKey    = '337de965aa1699e2f780c62520e1d695';

  // ------------------------------------------------------------------
  //  End-points (relative to baseUrl)
  // ------------------------------------------------------------------
  static const String _auth = '/api/v1/auth';

  static const String register          = '$_auth/register';
  static const String login             = '$_auth/login';
  static const String forgotPassword    = '$_auth/forgot-password';
  static const String resetPassword     = '$_auth/reset-password'; // + /:token
  static const String refreshToken      = '$_auth/refresh-token';
  static const String logout            = '$_auth/logout';

  static const String verifyEmail       = '/api/v1/verify-email';   // + /:token
  static const String currentUser       = '/api/v1/me';

  // ------------------------------------------------------------------
  //  Timeouts & Retry
  // ------------------------------------------------------------------
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;
}