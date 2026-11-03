import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android TV escape hatch: open a watch URL in the YouTube TV/app.
/// tvOS has no equivalent Intent pattern — stay in-app (see docs/tvos.md).
class YoutubeIntent {
  static Future<bool> openWatchUrl(String videoId) async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.android) {
      debugPrint('YoutubeIntent: unsupported on $defaultTargetPlatform');
      return false;
    }

    final uri = 'https://www.youtube.com/watch?v=$videoId';
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        data: uri,
      );
      await intent.launch();
      return true;
    } on PlatformException catch (e) {
      debugPrint('YoutubeIntent failed: $e');
      return false;
    }
  }
}
