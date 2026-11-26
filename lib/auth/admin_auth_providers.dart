import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_auth_service.dart';
import 'admin_biometric_gate.dart';

final adminBiometricGateProvider = Provider<AdminBiometricGate>((ref) {
  return LocalAuthBiometricGate();
});

final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService(
    biometricGate: ref.watch(adminBiometricGateProvider),
  );
});

final adminSessionProvider =
    StateNotifierProvider<AdminSessionController, AsyncValue<AdminSession>>(
  (ref) => AdminSessionController(ref.watch(adminAuthServiceProvider)),
);

class AdminSessionController extends StateNotifier<AsyncValue<AdminSession>> {
  AdminSessionController(this._auth) : super(const AsyncValue.loading()) {
    _restore();
  }

  final AdminAuthService _auth;

  Future<void> _restore() async {
    try {
      await _auth.bootstrapFromDartDefine();
      final session = await _auth.currentSession();
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.login(email: email, password: password);
    if (result.success && result.session != null) {
      state = AsyncValue.data(result.session!);
    }
    return result;
  }

  Future<AdminAuthResult> unlockWithBiometric({
    required String localizedReason,
  }) async {
    final result =
        await _auth.unlockWithBiometric(localizedReason: localizedReason);
    if (result.success && result.session != null) {
      state = AsyncValue.data(result.session!);
    }
    return result;
  }

  Future<AdminAuthResult> enableBiometricUnlock({
    required String localizedReason,
  }) async {
    return _auth.enableBiometricUnlock(localizedReason: localizedReason);
  }

  Future<void> disableBiometricUnlock() => _auth.disableBiometricUnlock();

  Future<void> logout() async {
    await _auth.logout();
    state = const AsyncValue.data(AdminSession.guest());
  }

  bool get isAdmin => state.valueOrNull?.isAdmin ?? false;
}

/// Convenience: true only when an admin session is active.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(adminSessionProvider).valueOrNull?.isAdmin ?? false;
});
