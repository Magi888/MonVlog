import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/auth/admin_auth_service.dart';
import 'package:monvlog/auth/admin_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory secure storage stand-in for unit tests (no platform channels).
class _MemorySecureStorage {
  final map = <String, String>{};

  Future<String?> read({required String key}) async => map[key];

  Future<void> write({required String key, required String value}) async {
    map[key] = value;
  }
}

/// Test-double AdminAuthService that uses memory maps instead of plugins.
class _TestAdminAuth {
  _TestAdminAuth() {
    SharedPreferences.setMockInitialValues({});
  }

  final _secure = _MemorySecureStorage();
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  static const _passwordHashKey = 'admin_password_sha256';
  static const _sessionEmailKey = 'admin_session_email';
  static const _sessionActiveKey = 'admin_session_active';

  Future<void> bootstrap(String password) async {
    final existing = await _secure.read(key: _passwordHashKey);
    if (existing != null && existing.isNotEmpty) return;
    await _secure.write(
      key: _passwordHashKey,
      value: AdminAuthService.hashPassword(password),
    );
  }

  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    if (!AdminConfig.isAdminEmail(email)) {
      return const AdminAuthResult.failure(AdminAuthResult.onlySeededAdmin);
    }
    final stored = await _secure.read(key: _passwordHashKey);
    final hash = AdminAuthService.hashPassword(password);
    if (stored == null || stored != hash) {
      return const AdminAuthResult.failure(AdminAuthResult.invalidCredentials);
    }
    final prefs = await _p;
    await prefs.setBool(_sessionActiveKey, true);
    await prefs.setString(_sessionEmailKey, AdminConfig.seedEmail);
    return AdminAuthResult.success(
      AdminSession(email: AdminConfig.seedEmail, isAdmin: true),
    );
  }

  Future<AdminSession> currentSession() async {
    final prefs = await _p;
    final active = prefs.getBool(_sessionActiveKey) ?? false;
    final email = prefs.getString(_sessionEmailKey) ?? '';
    if (!active || !AdminConfig.isAdminEmail(email)) {
      return const AdminSession.guest();
    }
    return AdminSession(email: email, isAdmin: true);
  }

  Future<void> logout() async {
    final prefs = await _p;
    await prefs.setBool(_sessionActiveKey, false);
    await prefs.remove(_sessionEmailKey);
  }
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
      final auth = _TestAdminAuth();
      await auth.bootstrap('test-pass');
      final result = await auth.login(
        email: 'other@example.com',
        password: 'test-pass',
      );
      expect(result.success, isFalse);
      expect(result.message, AdminAuthResult.onlySeededAdmin);
    });

    test('accepts seeded admin with matching password', () async {
      final auth = _TestAdminAuth();
      await auth.bootstrap('test-pass');
      final result = await auth.login(
        email: 'maag888@gmail.com',
        password: 'test-pass',
      );
      expect(result.success, isTrue);
      expect(result.session?.isAdmin, isTrue);
      final session = await auth.currentSession();
      expect(session.isAdmin, isTrue);
    });

    test('rejects wrong password', () async {
      final auth = _TestAdminAuth();
      await auth.bootstrap('test-pass');
      final result = await auth.login(
        email: 'maag888@gmail.com',
        password: 'wrong',
      );
      expect(result.success, isFalse);
    });

    test('logout returns guest', () async {
      final auth = _TestAdminAuth();
      await auth.bootstrap('test-pass');
      await auth.login(email: 'maag888@gmail.com', password: 'test-pass');
      await auth.logout();
      final session = await auth.currentSession();
      expect(session.isGuest, isTrue);
    });
  });
}
