import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_config.dart';

/// Admin login + role gate. Compile-time password (default or dart-define
/// override) is hashed into flutter_secure_storage for verification.
class AdminAuthService {
  AdminAuthService({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? prefs,
  })  : _secure = secureStorage ?? const FlutterSecureStorage(),
        _prefsOverride = prefs;

  static const _passwordHashKey = 'admin_password_sha256';
  static const _sessionEmailKey = 'admin_session_email';
  static const _sessionActiveKey = 'admin_session_active';

  final FlutterSecureStorage _secure;
  final SharedPreferences? _prefsOverride;
  SharedPreferences? _prefs;

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
      return const AdminAuthResult.failure(
        'Only the seeded admin account can sign in.',
      );
    }

    final candidate = password.trim();
    if (candidate.isEmpty) {
      return const AdminAuthResult.failure('Password is required.');
    }

    final ok = await _passwordMatches(candidate);
    if (!ok) {
      return const AdminAuthResult.failure('Invalid email or password.');
    }

    // Keep storage in sync if define was used before first bootstrap completed.
    await bootstrapFromDartDefine();
    if (!await hasStoredPassword && AdminConfig.hasPasswordDefine) {
      await _secure.write(
        key: _passwordHashKey,
        value: hashPassword(AdminConfig.passwordFromDefine),
      );
    }

    final prefs = await _prefsOrGet();
    await prefs.setBool(_sessionActiveKey, true);
    await prefs.setString(_sessionEmailKey, AdminConfig.seedEmail);

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

  Future<void> logout() async {
    final prefs = await _prefsOrGet();
    await prefs.setBool(_sessionActiveKey, false);
    await prefs.remove(_sessionEmailKey);
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

  final bool success;
  final AdminSession? session;
  final String message;
}
