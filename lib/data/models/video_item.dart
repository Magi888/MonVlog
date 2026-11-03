class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    this.durationLabel = '',
    this.channelId = '',
    this.description = '',
    this.publishedAt,
    this.viewCount,
  });

  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String durationLabel;
  final String channelId;
  final String description;
  final DateTime? publishedAt;
  final int? viewCount;

  VideoItem copyWith({
    String? id,
    String? title,
    String? channelName,
    String? thumbnailUrl,
    String? durationLabel,
    String? channelId,
    String? description,
    DateTime? publishedAt,
    int? viewCount,
  }) {
    return VideoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      channelName: channelName ?? this.channelName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationLabel: durationLabel ?? this.durationLabel,
      channelId: channelId ?? this.channelId,
      description: description ?? this.description,
      publishedAt: publishedAt ?? this.publishedAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channelName': channelName,
        'thumbnailUrl': thumbnailUrl,
        'durationLabel': durationLabel,
        'channelId': channelId,
        'description': description,
        'publishedAt': publishedAt?.toIso8601String(),
        'viewCount': viewCount,
      };

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      channelName: json['channelName'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      durationLabel: json['durationLabel'] as String? ?? '',
      channelId: json['channelId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      publishedAt: json['publishedAt'] is String
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      viewCount: json['viewCount'] is int ? json['viewCount'] as int : null,
    );
  }
}
