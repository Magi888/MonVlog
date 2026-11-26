/// Compile-time admin bootstrap via `--dart-define` (optional override).
///
/// Seed identity is fixed. Builds ship with a private-app default password so
/// local release APKs work without remembering `--dart-define`. Override at
/// run/build time when needed:
///
/// ```sh
/// flutter run \
///   --dart-define=ADMIN_PASSWORD=your-override \
///   --dart-define=YOUTUBE_API_KEY=optional
/// ```
///
/// On launch the effective password is hashed into flutter_secure_storage so
/// login can verify against the stored hash (updated when the compile-time
/// value changes).
class AdminConfig {
  AdminConfig._();

  /// Seeded admin email (public identity; not a secret).
  static const String seedEmail = 'maag888@gmail.com';

  /// Effective admin password: `--dart-define=ADMIN_PASSWORD=...` when set,
  /// otherwise the private-app default so release builds authenticate without
  /// an extra define.
  static const String passwordFromDefine = String.fromEnvironment(
    'ADMIN_PASSWORD',
    defaultValue: 'Poloiw247',
  );

  static bool get hasPasswordDefine => passwordFromDefine.trim().isNotEmpty;

  static bool isAdminEmail(String email) =>
      email.trim().toLowerCase() == seedEmail;
}
