/// One entry in the curated Mongolian-creator allowlist.
class CuratedChannel {
  const CuratedChannel({
    required this.channelId,
    required this.displayName,
    required this.category,
    required this.verified,
    this.handle = '',
    this.notes = '',
  });

  final String channelId;
  final String displayName;
  final String category;
  final bool verified;
  final String handle;
  final String notes;

  bool get isStub => !verified || channelId.contains('STUB');

  factory CuratedChannel.fromJson(Map<String, dynamic> json) {
    return CuratedChannel(
      channelId: json['channelId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      category: json['category'] as String? ?? 'daily',
      verified: json['verified'] as bool? ?? false,
      handle: json['handle'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'channelId': channelId,
        'displayName': displayName,
        'category': category,
        'verified': verified,
        'handle': handle,
        'notes': notes,
      };
}

/// Parsed curated-channels document (in-repo JSON or remote).
class CuratedCatalogConfig {
  const CuratedCatalogConfig({
    required this.version,
    required this.channels,
    this.source = 'in-repo',
  });

  final int version;
  final String source;
  final List<CuratedChannel> channels;

  /// Channels safe to hit with the YouTube Data API (real UC IDs).
  List<CuratedChannel> get apiReady =>
      channels.where((c) => !c.isStub && c.channelId.startsWith('UC')).toList();

  factory CuratedCatalogConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['channels'];
    final list = <CuratedChannel>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(CuratedChannel.fromJson(item));
        } else if (item is Map) {
          list.add(CuratedChannel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CuratedCatalogConfig(
      version: json['version'] is int ? json['version'] as int : 1,
      source: json['source'] as String? ?? 'in-repo',
      channels: list,
    );
  }
}
