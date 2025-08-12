/// Network configuration – infrastructure constants only.
/// Do **not** import this in domain or presentation code.
class NetworkConfigs {
  // ------------------------------------------------------------------
  //  Environment – switch via dart-define or flavor
  // ------------------------------------------------------------------
  static const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static String get baseUrl => switch (_env) {
        'prod' => 'http://192.168.15.148:5001/api/v1',
        'stg'  => 'http://192.168.15.148:5001/api/v1',
        _      => 'http://192.168.15.36:5001/api/v1', // dev
      };

  // ------------------------------------------------------------------
  //  Auth & Global headers
  // ------------------------------------------------------------------
  static const String apiToken  = String.fromEnvironment('API_TOKEN');  // empty in dev
  static const String apiKey    = '337de965aa1699e2f780c62520e1d695';

  // ------------------------------------------------------------------
  //  End-points (relative to baseUrl)
  // ------------------------------------------------------------------
  static const String _auth = '/auth';  // ✅ 

  static const String register          = '$_auth/register';
  static const String login             = '$_auth/login';
  static const String forgotPassword    = '$_auth/forgot-password';
  static const String resetPassword     = '$_auth/reset-password'; // + /:token
  static const String refreshToken      = '$_auth/refresh-token';
  static const String logout            = '$_auth/logout';
  static const String sendVerificationEmail       = '$_auth/resend-verification';

  static const String verifyEmail       = '/verify-email';   // ✅ 
  static const String currentUser       = '/me';             // ✅ 

  // ------------------------------------------------------------------
  //  Timeouts & Retry
  // ------------------------------------------------------------------
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const int maxRetries = 2;
}