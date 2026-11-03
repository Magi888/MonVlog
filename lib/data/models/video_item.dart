class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    this.durationLabel = '',
  });

  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String durationLabel;
}
