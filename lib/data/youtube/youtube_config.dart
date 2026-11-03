/// Compile-time YouTube / catalog config via `--dart-define`.
///
/// ```sh
/// flutter run --dart-define=YOUTUBE_API_KEY=YOUR_KEY
/// # optional remote allowlist:
/// flutter run --dart-define=YOUTUBE_API_KEY=YOUR_KEY \
///   --dart-define=CURATED_CHANNELS_URL=https://example.com/curated_channels.json
/// ```
class YoutubeConfig {
  YoutubeConfig._();

  static const String apiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );

  /// Optional HTTPS URL that returns the same JSON shape as
  /// `assets/config/curated_channels.json`. Empty → load in-repo asset.
  static const String curatedChannelsUrl = String.fromEnvironment(
    'CURATED_CHANNELS_URL',
    defaultValue: '',
  );

  static bool get hasApiKey => apiKey.trim().isNotEmpty;

  static bool get hasRemoteCuratedUrl => curatedChannelsUrl.trim().isNotEmpty;
}
