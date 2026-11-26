import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Local device biometric / credential unlock (fingerprint, face, PIN).
///
/// This is **not** server WebAuthn — MonVlog has no auth backend. After the
/// first email+password admin login, the device can re-open the admin session
/// via [LocalAuthentication].
abstract class AdminBiometricGate {
  /// Hardware can check biometrics and/or device credentials.
  Future<bool> get canAuthenticate;

  /// Prompt the OS unlock UI. Returns false on cancel / soft failure.
  Future<bool> authenticate({required String localizedReason});
}

/// Production gate backed by [local_auth].
class LocalAuthBiometricGate implements AdminBiometricGate {
  LocalAuthBiometricGate({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> get canAuthenticate async {
    // Plugin channels are unavailable on web / some desktop/test hosts.
    if (kIsWeb) return false;
    try {
      final biometrics = await _auth.canCheckBiometrics;
      final device = await _auth.isDeviceSupported();
      return biometrics || device;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        // Prefer biometrics; still allow device PIN/pattern as fallback so
        // phones without enrolled fingerprints remain usable.
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Deterministic stand-in for unit / widget tests (no platform channels).
class FakeBiometricGate implements AdminBiometricGate {
  FakeBiometricGate({
    this.supported = true,
    this.authenticateResult = true,
  });

  bool supported;
  bool authenticateResult;
  int authenticateCalls = 0;
  String? lastReason;

  @override
  Future<bool> get canAuthenticate async => supported;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticateCalls += 1;
    lastReason = localizedReason;
    return authenticateResult;
  }
}
