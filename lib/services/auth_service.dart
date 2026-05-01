import 'package:local_auth/local_auth.dart';

class AuthService {
  AuthService._();
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isAvail  = await _auth.isDeviceSupported();
    return canCheck && isAvail;
  }

  static Future<bool> authenticate({
    String reason = 'Verify your identity to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}