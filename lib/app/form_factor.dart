import 'package:flutter/widgets.dart';

/// Rough form-factor helpers for phone vs living-room / TV layouts.
class FormFactor {
  /// Wide landscape living-room viewport → TV / leanback splash destination.
  /// Phone and default test surfaces stay on the community shell.
  static bool isTvLayout(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;
    // Require a clear TV-sized canvas (e.g. 1280×720), not tablets or 800×600 tests.
    return landscape && size.width >= 1100 && size.height >= 600;
  }

  static bool isPhoneLayout(BuildContext context) => !isTvLayout(context);
}
