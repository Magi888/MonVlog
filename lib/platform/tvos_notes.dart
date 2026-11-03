/// Compile-time markers for the Apple TV path.
///
/// Official Flutter has no `tvos` create target. See `docs/tvos.md` for the
/// flutter-tvos toolchain used to add a real `tvos/` runner on macOS + Xcode.
class TvOsNotes {
  static const bool officialFlutterTvOs = false;
  static const String toolchain = 'https://github.com/fluttertv/flutter-tvos';
  static const String docPath = 'docs/tvos.md';
}
