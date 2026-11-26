import 'package:flutter/widgets.dart';

import '../platform/android_tv.dart';

/// Rough form-factor helpers for phone vs living-room / TV layouts.
class FormFactor {
  /// Wide landscape living-room viewport → TV / leanback splash destination.
  ///
  /// Also true when the Android host reports television UI mode (leanback),
  /// even if MediaQuery size is atypical after rotation or overscan.
  ///
  /// Defaults to **phone** for tablets, desktop web, and narrow windows so the
  /// Community / Watch / Profile bottom menu stays reachable. Only clear
  /// 720p+ landscape canvases (e.g. 1280×720) or native TV take the TV shell.
  static bool isTvLayout(BuildContext context) {
    if (AndroidTv.isTelevision) return true;
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;
    return landscape && size.width >= 1280 && size.height >= 720;
  }

  static bool isPhoneLayout(BuildContext context) => !isTvLayout(context);
}
