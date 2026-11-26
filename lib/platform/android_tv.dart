import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native Android TV / Google TV detection via [UiModeManager].
///
/// Viewport heuristics alone can miss some leanback devices; call [init]
/// once at startup so [FormFactor.isTvLayout] prefers the living-room shell.
class AndroidTv {
  AndroidTv._();

  static const _channel = MethodChannel('com.monvlog.monvlog/tv');

  /// True when the host reports [Configuration.UI_MODE_TYPE_TELEVISION].
  static bool isTelevision = false;

  /// Reads the native UI mode. Safe to call on non-Android (no-op).
  static Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) {
      isTelevision = false;
      return;
    }
    try {
      final value = await _channel.invokeMethod<bool>('isTelevision');
      isTelevision = value ?? false;
    } on MissingPluginException {
      isTelevision = false;
    } on PlatformException {
      isTelevision = false;
    }
  }
}
