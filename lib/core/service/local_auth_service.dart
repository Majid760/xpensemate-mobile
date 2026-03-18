import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

class LocalAuthService {
  LocalAuthService(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<bool> canAuthenticate() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      logE('LocalAuthService: Error checking biometric support: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) {
        logW('LocalAuthService: Device does not support local authentication');
        return false;
      }
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        logW('LocalAuthService: Biometrics not available');
      } else if (e.code == 'NotEnrolled') {
        logW('LocalAuthService: Biometrics not enrolled');
      } else {
        logE('LocalAuthService: Error during authentication: $e');
      }
      return false;
    }
  }
}
