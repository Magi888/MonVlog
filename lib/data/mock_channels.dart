/// Mock video-channel cards for the phone community "All Video Channels" list.
class MockVideoChannel {
  const MockVideoChannel({
    required this.id,
    required this.name,
    required this.videoCount,
    required this.bannerSeed,
    this.tierKey = 'free',
    this.actionKey = 'view',
  });

  final String id;
  final String name;
  final int videoCount;
  final String bannerSeed;

  /// `free` → [AppLocalizations.freeTier]
  final String tierKey;

  /// `view` | `manage` → viewChannel / manage
  final String actionKey;

  String get bannerUrl =>
      'https://picsum.photos/seed/$bannerSeed/640/280';
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
    ),
    MockVideoChannel(
      id: 'tselmeg',
      name: 'Tselmeg Vlog',
      videoCount: 96,
      bannerSeed: 'monvlog-ch-tselmeg',
    ),
    MockVideoChannel(
      id: 'positive',
      name: 'Positive Mongolians',
      videoCount: 142,
      bannerSeed: 'monvlog-ch-positive',
    ),
  ];
}
