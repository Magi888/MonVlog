import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/auth/admin_auth_service.dart';
import 'package:monvlog/auth/admin_biometric_gate.dart';
import 'package:monvlog/auth/admin_config.dart';
import 'package:monvlog/auth/admin_secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

AdminAuthService buildAuth({
  FakeBiometricGate? gate,
  MemoryAdminSecureStore? store,
}) {
  SharedPreferences.setMockInitialValues({});
  return AdminAuthService(
    secureStore: store ?? MemoryAdminSecureStore(),
    biometricGate: gate ?? FakeBiometricGate(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminConfig', () {
    test('seed email is maag888@gmail.com', () {
      expect(AdminConfig.seedEmail, 'maag888@gmail.com');
      expect(AdminConfig.isAdminEmail('maag888@gmail.com'), isTrue);
      expect(AdminConfig.isAdminEmail('MAAG888@GMAIL.COM'), isTrue);
      expect(AdminConfig.isAdminEmail('viewer@example.com'), isFalse);
    });

    test('password has private-app default (dart-define can override)', () {
      expect(AdminConfig.passwordFromDefine, isNotEmpty);
      expect(AdminConfig.hasPasswordDefine, isTrue);
    });
  });

  group('AdminAuthService.hashPassword', () {
    test('is deterministic and not plaintext', () {
      final a = AdminAuthService.hashPassword('secret');
      final b = AdminAuthService.hashPassword('secret');
      expect(a, b);
      expect(a, isNot('secret'));
      expect(a.length, 64); // sha256 hex
    });
  });

  group('admin login role gate', () {
    test('rejects non-admin email', () async {
      final auth = buildAuth();
      await auth.bootstrapFromDartDefine();
      final result = await auth.login(
        email: 'other@example.com',
        password: AdminConfig.passwordFromDefine,
      );
      expect(result.success, isFalse);
      expect(result.message, AdminAuthResult.onlySeededAdmin);
    });

    test('accepts seeded admin with matching password', () async {
      final auth = buildAuth();
      await auth.bootstrapFromDartDefine();
      final result = await auth.login(
        email: 'maag888@gmail.com',
        password: AdminConfig.passwordFromDefine,
      );
      expect(result.success, isTrue);
      expect(result.session?.isAdmin, isTrue);
      final session = await auth.currentSession();
      expect(session.isAdmin, isTrue);
    });

    test('rejects wrong password', () async {
      final auth = buildAuth();
      await auth.bootstrapFromDartDefine();
      final result = await auth.login(
        email: 'maag888@gmail.com',
        password: 'wrong',
      );
      expect(result.success, isFalse);
    });

    test('logout returns guest but keeps biometric opt-in', () async {
      final gate = FakeBiometricGate();
      final auth = buildAuth(gate: gate);
      await auth.bootstrapFromDartDefine();
      await auth.login(
        email: 'maag888@gmail.com',
        password: AdminConfig.passwordFromDefine,
      );
      final enabled = await auth.enableBiometricUnlock(
        localizedReason: 'enable',
      );
      expect(enabled.success, isTrue);
      expect(await auth.isBiometricUnlockEnabled, isTrue);

      await auth.logout();
      final session = await auth.currentSession();
      expect(session.isGuest, isTrue);
      expect(await auth.isBiometricUnlockEnabled, isTrue);
      expect(await auth.canBiometricUnlock, isTrue);
    });
  });

  group('admin biometric unlock', () {
    test('enable requires active admin session', () async {
      final auth = buildAuth();
      final result = await auth.enableBiometricUnlock(
        localizedReason: 'enable',
      );
      expect(result.success, isFalse);
      expect(result.message, AdminAuthResult.biometricNotAdmin);
    });

    test('unlock restores session after biometric success', () async {
      final gate = FakeBiometricGate();
      final auth = buildAuth(gate: gate);
      await auth.bootstrapFromDartDefine();
      await auth.login(
        email: 'maag888@gmail.com',
        password: AdminConfig.passwordFromDefine,
      );
      await auth.enableBiometricUnlock(localizedReason: 'enable');
      await auth.logout();

      final unlocked = await auth.unlockWithBiometric(
        localizedReason: 'unlock',
      );
      expect(unlocked.success, isTrue);
      expect((await auth.currentSession()).isAdmin, isTrue);
      expect(gate.authenticateCalls, greaterThanOrEqualTo(2));
      expect(gate.lastReason, 'unlock');
    });

    test('unlock fails when biometric prompt is canceled', () async {
      final gate = FakeBiometricGate(authenticateResult: true);
      final auth = buildAuth(gate: gate);
      await auth.bootstrapFromDartDefine();
      await auth.login(
        email: 'maag888@gmail.com',
        password: AdminConfig.passwordFromDefine,
      );
      await auth.enableBiometricUnlock(localizedReason: 'enable');
      await auth.logout();

      gate.authenticateResult = false;
      final unlocked = await auth.unlockWithBiometric(
        localizedReason: 'unlock',
      );
      expect(unlocked.success, isFalse);
      expect(unlocked.message, AdminAuthResult.biometricFailed);
      expect((await auth.currentSession()).isGuest, isTrue);
    });

    test('password remains available as fallback', () async {
      final gate = FakeBiometricGate(authenticateResult: false);
      final auth = buildAuth(gate: gate);
      await auth.bootstrapFromDartDefine();
      // Even with biometrics failing, password login still works.
      final result = await auth.login(
        email: 'maag888@gmail.com',
        password: AdminConfig.passwordFromDefine,
      );
      expect(result.success, isTrue);
    });

    test('disableBiometricUnlock blocks later unlock', () async {
      final gate = FakeBiometricGate();
      final auth = buildAuth(gate: gate);
      await auth.bootstrapFromDartDefine();
      await auth.login(
        email: 'maag888@gmail.com',
        password: AdminConfig.passwordFromDefine,
      );
      await auth.enableBiometricUnlock(localizedReason: 'enable');
      await auth.disableBiometricUnlock();
      await auth.logout();

      final unlocked = await auth.unlockWithBiometric(
        localizedReason: 'unlock',
      );
      expect(unlocked.success, isFalse);
      expect(unlocked.message, AdminAuthResult.biometricNotEnabled);
    });
  });
}
