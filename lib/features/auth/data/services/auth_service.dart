import 'package:google_sign_in/google_sign_in.dart';
import 'package:xpensemate/core/network/network_configs.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;



  Future<String> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn
      await _googleSignIn.initialize(
        clientId: NetworkConfigs.googleAuthClientId,
      );

      // Check if platform supports authenticate
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.authenticate(scopeHint: ['email']);
        
        // Listen to authentication events to get the signed-in user
        GoogleSignInAccount? googleUser;
        await for (final event in _googleSignIn.authenticationEvents) {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            googleUser = event.user;
            break;
          }
        }
        
        if (googleUser == null) {
          throw Exception('Google sign in was cancelled');
        }

        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;
        
        if (idToken == null) {
          throw Exception('Failed to get Google ID token');
        }
        return idToken;
      } else {
        throw Exception('This platform does not support Google authentication');
      }
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }




}