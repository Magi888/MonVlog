import 'package:flutter/widgets.dart';

/// Rough form-factor helpers for phone vs living-room / TV layouts.
class FormFactor {
  /// Wide landscape living-room viewport → TV / leanback splash destination.
  ///
  /// Defaults to **phone** for tablets, desktop web, and narrow windows so the
  /// Community / Watch / Profile bottom menu stays reachable. Only clear
  /// 720p+ landscape canvases (e.g. 1280×720) take the TV shell.
  static bool isTvLayout(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;
    return landscape && size.width >= 1280 && size.height >= 720;
  }

  static bool isPhoneLayout(BuildContext context) => !isTvLayout(context);
}
