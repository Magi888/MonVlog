/// Mock video-channel cards for the phone community "All Video Channels" list.
class MockVideoChannel {
  const MockVideoChannel({
    required this.id,
    required this.name,
    required this.videoCount,
    required this.bannerSeed,
    this.youtubeChannelId = '',
    this.tierKey = 'free',
    this.actionKey = 'view',
  });

  final String id;
  final String name;
  final int videoCount;
  final String bannerSeed;

  /// Curated YouTube UC id when known (opens real channel browse).
  final String youtubeChannelId;

  /// `free` → [AppLocalizations.freeTier]
  final String tierKey;

  /// `view` | `manage` → viewChannel / manage
  final String actionKey;

  String get bannerUrl =>
      'https://picsum.photos/seed/$bannerSeed/640/280';

  /// Route id for `/channel/:id` — prefers real UC id.
  String get browseId =>
      youtubeChannelId.isNotEmpty ? youtubeChannelId : id;
}

/// Curated mock channels inspired by the Wix Spaces Monvlog.com community.
class MockChannels {
  static const List<MockVideoChannel> all = [
    MockVideoChannel(
      id: 'anu',
      name: 'Anu Harchu',
      videoCount: 581,
      bannerSeed: 'monvlog-ch-anu',
    ),
    MockVideoChannel(
      id: 'we-are',
      name: 'We are Mongolians',
      videoCount: 70,
      bannerSeed: 'monvlog-ch-weare',
    ),
    MockVideoChannel(
      id: 'uzdeg',
      name: 'Үз+Дэг ОниГоо',
      videoCount: 10,
      bannerSeed: 'monvlog-ch-uzdeg',
      actionKey: 'manage',
    ),
    MockVideoChannel(
      id: 'gremix',
      name: 'Gremix',
      videoCount: 214,
      bannerSeed: 'monvlog-ch-gremix',
      youtubeChannelId: 'UCQXxhQHalYjwMictp1lUbtg',
    ),
    MockVideoChannel(
      id: 'tselmeg',
      name: 'Tselmeg Vlog',
      videoCount: 96,
      bannerSeed: 'monvlog-ch-tselmeg',
      youtubeChannelId: 'UCIsvomXQNyFRjpAP_GyWI-Q',
    ),
    MockVideoChannel(
      id: 'positive',
      name: 'Positive Mongolians',
      videoCount: 142,
      bannerSeed: 'monvlog-ch-positive',
      youtubeChannelId: 'UCXr6n3L8EDVQR-_EUJc-2Nw',
    ),
  ];
}
