/// Compile-time admin bootstrap via `--dart-define`.
///
/// Seed identity is fixed. Password must never be committed — pass it only at
/// run/build time:
///
/// ```sh
/// flutter run \
///   --dart-define=ADMIN_PASSWORD=your-secret \
///   --dart-define=YOUTUBE_API_KEY=optional
/// ```
///
/// On first launch the password is hashed into flutter_secure_storage so later
/// runs can authenticate without re-supplying the define (until storage is
/// cleared).
class AdminConfig {
  AdminConfig._();

  /// Seeded admin email (public identity; not a secret).
  static const String seedEmail = 'maag888@gmail.com';

  /// Password from `--dart-define=ADMIN_PASSWORD=...` only. Never commit a value.
  static const String passwordFromDefine = String.fromEnvironment(
    'ADMIN_PASSWORD',
    defaultValue: '',
  );

  static bool get hasPasswordDefine => passwordFromDefine.trim().isNotEmpty;

  static bool isAdminEmail(String email) =>
      email.trim().toLowerCase() == seedEmail;
}
