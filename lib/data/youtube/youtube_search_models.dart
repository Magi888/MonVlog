/// Result row from YouTube `search.list` (channel or playlist) or mock.
class YoutubeSearchHit {
  const YoutubeSearchHit({
    required this.kind,
    required this.id,
    required this.title,
    this.description = '',
    this.thumbnailUrl = '',
    this.channelId = '',
    this.channelTitle = '',
    this.isMock = false,
  });

  /// `channel` or `playlist`
  final String kind;
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelId;
  final String channelTitle;
  final bool isMock;

  bool get isChannel => kind == 'channel';
  bool get isPlaylist => kind == 'playlist';
}

class YoutubeChannelSearchResult {
  const YoutubeChannelSearchResult({
    required this.hits,
    required this.isMock,
    this.message = '',
  });

  final List<YoutubeSearchHit> hits;
  final bool isMock;
  final String message;
}
