import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_biometric_gate.dart';
import 'admin_config.dart';
import 'admin_secure_store.dart';

/// Admin login + role gate. Compile-time password (default or dart-define
/// override) is hashed into secure storage for verification.
///
/// Optional local-device biometric unlock: after one successful password login
/// the admin can enable [local_auth] re-entry; password remains the fallback.
class AdminAuthService {
  AdminAuthService({
    AdminSecureStore? secureStore,
    SharedPreferences? prefs,
    AdminBiometricGate? biometricGate,
  })  : _secure = secureStore ?? FlutterAdminSecureStore(),
        _prefsOverride = prefs,
        _biometric = biometricGate ?? LocalAuthBiometricGate();

  static const _passwordHashKey = 'admin_password_sha256';
  static const _sessionEmailKey = 'admin_session_email';
  static const _sessionActiveKey = 'admin_session_active';
  static const _biometricEnabledKey = 'admin_biometric_unlock_enabled';

  final AdminSecureStore _secure;
  final SharedPreferences? _prefsOverride;
  final AdminBiometricGate _biometric;
  SharedPreferences? _prefs;

  AdminBiometricGate get biometricGate => _biometric;

  Future<SharedPreferences> _prefsOrGet() async {
    return _prefsOverride ?? (_prefs ??= await SharedPreferences.getInstance());
  }

  /// Hash used for comparison — never store plaintext in prefs.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    return sha256.convert(bytes).toString();
  }

  /// Persist (or refresh) the hash of the compile-time admin password so
  /// builds that change the default / dart-define take effect without a
  /// manual storage wipe.
  Future<void> bootstrapFromDartDefine() async {
    final define = AdminConfig.passwordFromDefine.trim();
    if (define.isEmpty) return;

    try {
      final expected = hashPassword(define);
      final existing = await _secure.read(key: _passwordHashKey);
      if (existing == expected) return;

      await _secure.write(key: _passwordHashKey, value: expected);
    } catch (_) {
      // Platform channel missing (tests) or storage unavailable — define still
      // works for in-memory login comparison via [_passwordMatches].
    }
  }

  Future<bool> get hasStoredPassword async {
    try {
      final hash = await _secure.read(key: _passwordHashKey);
      return hash != null && hash.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// True when either secure storage or dart-define can verify a password.
  Future<bool> get canAuthenticate async {
    if (await hasStoredPassword) return true;
    return AdminConfig.hasPasswordDefine;
  }

  /// Device supports biometric / credential unlock UI.
  Future<bool> get canUseDeviceUnlock async => _biometric.canAuthenticate;

  /// Admin previously opted into local unlock after a password login.
  Future<bool> get isBiometricUnlockEnabled async {
    try {
      final v = await _secure.read(key: _biometricEnabledKey);
      return v == '1';
    } catch (_) {
      return false;
    }
  }

  /// Ready to show “Unlock with passkey / biometric” on the login screen.
  Future<bool> get canBiometricUnlock async {
    if (!await isBiometricUnlockEnabled) return false;
    return canUseDeviceUnlock;
  }

  Future<AdminSession> currentSession() async {
    final prefs = await _prefsOrGet();
    final active = prefs.getBool(_sessionActiveKey) ?? false;
    final email = prefs.getString(_sessionEmailKey) ?? '';
    if (!active || !AdminConfig.isAdminEmail(email)) {
      return const AdminSession.guest();
    }
    return AdminSession(email: email, isAdmin: true);
  }

  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (!AdminConfig.isAdminEmail(trimmedEmail)) {
      return const AdminAuthResult.failure(AdminAuthResult.onlySeededAdmin);
    }

    final candidate = password.trim();
    if (candidate.isEmpty) {
      return const AdminAuthResult.failure(AdminAuthResult.passwordRequired);
    }

    final ok = await _passwordMatches(candidate);
    if (!ok) {
      return const AdminAuthResult.failure(AdminAuthResult.invalidCredentials);
    }

    // Keep storage in sync if define was used before first bootstrap completed.
    await bootstrapFromDartDefine();
    if (!await hasStoredPassword && AdminConfig.hasPasswordDefine) {
      try {
        await _secure.write(
          key: _passwordHashKey,
          value: hashPassword(AdminConfig.passwordFromDefine),
        );
      } catch (_) {
        // Tests / missing plugin — session still activates below.
      }
    }

    await _activateSession();

    return AdminAuthResult.success(
      AdminSession(email: AdminConfig.seedEmail, isAdmin: true),
    );
  }

  /// Prompt device unlock, then mark biometric re-entry enabled.
  ///
  /// Call after a successful password login while the admin session is active.
  Future<AdminAuthResult> enableBiometricUnlock({
    required String localizedReason,
  }) async {
    final session = await currentSession();
    if (!session.isAdmin) {
      return const AdminAuthResult.failure(AdminAuthResult.biometricNotAdmin);
    }
    if (!await canUseDeviceUnlock) {
      return const AdminAuthResult.failure(
        AdminAuthResult.biometricUnavailable,
      );
    }

    final ok = await _biometric.authenticate(localizedReason: localizedReason);
    if (!ok) {
      return const AdminAuthResult.failure(AdminAuthResult.biometricFailed);
    }

    try {
      await _secure.write(key: _biometricEnabledKey, value: '1');
    } catch (_) {
      return const AdminAuthResult.failure(
        AdminAuthResult.biometricUnavailable,
      );
    }

    return AdminAuthResult.success(session);
  }

  Future<void> disableBiometricUnlock() async {
    try {
      await _secure.write(key: _biometricEnabledKey, value: '0');
    } catch (_) {
      // Best-effort — preference may already be missing.
    }
  }

  /// Restore the admin session after a successful device biometric / PIN.
  Future<AdminAuthResult> unlockWithBiometric({
    required String localizedReason,
  }) async {
    if (!await isBiometricUnlockEnabled) {
      return const AdminAuthResult.failure(AdminAuthResult.biometricNotEnabled);
    }
    if (!await canUseDeviceUnlock) {
      return const AdminAuthResult.failure(
        AdminAuthResult.biometricUnavailable,
      );
    }

    final ok = await _biometric.authenticate(localizedReason: localizedReason);
    if (!ok) {
      return const AdminAuthResult.failure(AdminAuthResult.biometricFailed);
    }

    await _activateSession();
    return AdminAuthResult.success(
      AdminSession(email: AdminConfig.seedEmail, isAdmin: true),
    );
  }

  Future<bool> _passwordMatches(String candidate) async {
    final candidateHash = hashPassword(candidate);
    try {
      final stored = await _secure.read(key: _passwordHashKey);
      if (stored != null && stored.isNotEmpty) {
        return stored == candidateHash;
      }
    } catch (_) {
      // Fall through to dart-define.
    }
    // First-run / storage-cleared path: compare against dart-define only.
    if (!AdminConfig.hasPasswordDefine) return false;
    return candidateHash == hashPassword(AdminConfig.passwordFromDefine);
  }

  Future<void> _activateSession() async {
    final prefs = await _prefsOrGet();
    await prefs.setBool(_sessionActiveKey, true);
    await prefs.setString(_sessionEmailKey, AdminConfig.seedEmail);
  }

  Future<void> logout() async {
    final prefs = await _prefsOrGet();
    await prefs.setBool(_sessionActiveKey, false);
    await prefs.remove(_sessionEmailKey);
    // Keep biometric opt-in so the next visit can unlock without password.
  }
}

class AdminSession {
  const AdminSession({required this.email, required this.isAdmin});

  const AdminSession.guest()
      : email = '',
        isAdmin = false;

  final String email;
  final bool isAdmin;

  bool get isGuest => !isAdmin;
}

class AdminAuthResult {
  const AdminAuthResult._({
    required this.success,
    this.session,
    this.message = '',
  });

  const AdminAuthResult.success(AdminSession session)
      : this._(success: true, session: session);

  const AdminAuthResult.failure(String message)
      : this._(success: false, message: message);

  /// Stable error codes — map to [AppLocalizations] in UI.
  static const onlySeededAdmin = 'only_seeded_admin';
  static const passwordRequired = 'password_required';
  static const invalidCredentials = 'invalid_credentials';
  static const biometricNotEnabled = 'biometric_not_enabled';
  static const biometricUnavailable = 'biometric_unavailable';
  static const biometricFailed = 'biometric_failed';
  static const biometricNotAdmin = 'biometric_not_admin';

  final bool success;
  final AdminSession? session;
  final String message;
}
