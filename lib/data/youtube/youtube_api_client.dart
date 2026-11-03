import 'package:dio/dio.dart';

import '../models/video_item.dart';
import 'youtube_config.dart';

/// Thin YouTube Data API v3 client (channels → uploads playlist → videos).
class YoutubeApiClient {
  YoutubeApiClient({
    Dio? dio,
    String? apiKey,
    this.baseUrl = 'https://www.googleapis.com/youtube/v3',
  })  : apiKey = apiKey ?? YoutubeConfig.apiKey,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;
  final String apiKey;
  final String baseUrl;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// `channels.list` — branding + uploads playlist ID.
  Future<List<YoutubeChannelMeta>> listChannels(List<String> channelIds) async {
    if (!isConfigured || channelIds.isEmpty) return const [];

    final response = await _dio.get<Map<String, dynamic>>(
      '/channels',
      queryParameters: {
        'part': 'snippet,contentDetails',
        'id': channelIds.join(','),
        'key': apiKey,
        'maxResults': 50,
      },
    );

    final items = response.data?['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map>()
        .map((raw) => YoutubeChannelMeta.fromJson(Map<String, dynamic>.from(raw)))
        .where((c) => c.id.isNotEmpty && c.uploadsPlaylistId.isNotEmpty)
        .toList();
  }

  /// `playlistItems.list` — recent uploads for a channel's uploads playlist.
  Future<List<VideoItem>> listPlaylistItems({
    required String playlistId,
    required String channelId,
    required String channelName,
    int maxResults = 8,
  }) async {
    if (!isConfigured || playlistId.isEmpty) return const [];

    final response = await _dio.get<Map<String, dynamic>>(
      '/playlistItems',
      queryParameters: {
        'part': 'snippet,contentDetails',
        'playlistId': playlistId,
        'maxResults': maxResults.clamp(1, 50),
        'key': apiKey,
      },
    );

    final items = response.data?['items'] as List<dynamic>? ?? const [];
    final videos = <VideoItem>[];
    for (final raw in items) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final parsed = _videoFromPlaylistItem(
        map,
        channelId: channelId,
        channelName: channelName,
      );
      if (parsed != null) videos.add(parsed);
    }
    return videos;
  }

  /// `search.list` constrained to a single allowlisted `channelId`.
  Future<List<VideoItem>> searchByChannel({
    required String channelId,
    required String channelName,
    String query = '',
    int maxResults = 8,
  }) async {
    if (!isConfigured || channelId.isEmpty) return const [];

    final response = await _dio.get<Map<String, dynamic>>(
      '/search',
      queryParameters: {
        'part': 'snippet',
        'channelId': channelId,
        'type': 'video',
        'order': 'date',
        if (query.isNotEmpty) 'q': query,
        'maxResults': maxResults.clamp(1, 50),
        'key': apiKey,
      },
    );

    final items = response.data?['items'] as List<dynamic>? ?? const [];
    final videos = <VideoItem>[];
    for (final raw in items) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final idMap = map['id'];
      final videoId = idMap is Map
          ? (idMap['videoId'] as String? ?? '')
          : '';
      final snippet = map['snippet'];
      if (videoId.isEmpty || snippet is! Map) continue;
      final sn = Map<String, dynamic>.from(snippet);
      videos.add(
        VideoItem(
          id: videoId,
          title: sn['title'] as String? ?? '',
          channelName: sn['channelTitle'] as String? ?? channelName,
          channelId: sn['channelId'] as String? ?? channelId,
          thumbnailUrl: _bestThumbnail(sn['thumbnails']),
          description: sn['description'] as String? ?? '',
          publishedAt: DateTime.tryParse(sn['publishedAt'] as String? ?? ''),
        ),
      );
    }
    return videos;
  }

  /// `videos.list` — duration, stats, fuller description.
  Future<List<VideoItem>> enrichVideos(List<VideoItem> videos) async {
    if (!isConfigured || videos.isEmpty) return videos;

    final byId = {for (final v in videos) v.id: v};
    final ids = byId.keys.where((id) => id.isNotEmpty).toList();
    if (ids.isEmpty) return videos;

    final response = await _dio.get<Map<String, dynamic>>(
      '/videos',
      queryParameters: {
        'part': 'snippet,contentDetails,statistics',
        'id': ids.take(50).join(','),
        'key': apiKey,
      },
    );

    final items = response.data?['items'] as List<dynamic>? ?? const [];
    for (final raw in items) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final id = map['id'] as String? ?? '';
      final existing = byId[id];
      if (existing == null) continue;

      final snippet = map['snippet'] is Map
          ? Map<String, dynamic>.from(map['snippet'] as Map)
          : const <String, dynamic>{};
      final content = map['contentDetails'] is Map
          ? Map<String, dynamic>.from(map['contentDetails'] as Map)
          : const <String, dynamic>{};
      final stats = map['statistics'] is Map
          ? Map<String, dynamic>.from(map['statistics'] as Map)
          : const <String, dynamic>{};

      byId[id] = existing.copyWith(
        title: (snippet['title'] as String?)?.isNotEmpty == true
            ? snippet['title'] as String
            : existing.title,
        description: (snippet['description'] as String?)?.isNotEmpty == true
            ? snippet['description'] as String
            : existing.description,
        channelName: (snippet['channelTitle'] as String?)?.isNotEmpty == true
            ? snippet['channelTitle'] as String
            : existing.channelName,
        channelId: (snippet['channelId'] as String?)?.isNotEmpty == true
            ? snippet['channelId'] as String
            : existing.channelId,
        thumbnailUrl: _bestThumbnail(snippet['thumbnails']).isNotEmpty
            ? _bestThumbnail(snippet['thumbnails'])
            : existing.thumbnailUrl,
        durationLabel: formatIso8601Duration(
          content['duration'] as String? ?? '',
        ),
        publishedAt: DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
            existing.publishedAt,
        viewCount: int.tryParse(stats['viewCount'] as String? ?? '') ??
            existing.viewCount,
      );
    }

    return videos.map((v) => byId[v.id] ?? v).toList();
  }

  static VideoItem? _videoFromPlaylistItem(
    Map<String, dynamic> item, {
    required String channelId,
    required String channelName,
  }) {
    final snippet = item['snippet'];
    final content = item['contentDetails'];
    if (snippet is! Map) return null;

    final sn = Map<String, dynamic>.from(snippet);
    final resource = sn['resourceId'];
    var videoId = '';
    if (resource is Map) {
      videoId = resource['videoId'] as String? ?? '';
    }
    if (videoId.isEmpty && content is Map) {
      videoId = content['videoId'] as String? ?? '';
    }
    if (videoId.isEmpty) return null;

    return VideoItem(
      id: videoId,
      title: sn['title'] as String? ?? '',
      channelName: sn['channelTitle'] as String? ?? channelName,
      channelId: sn['channelId'] as String? ?? channelId,
      thumbnailUrl: _bestThumbnail(sn['thumbnails']),
      description: sn['description'] as String? ?? '',
      publishedAt: DateTime.tryParse(sn['publishedAt'] as String? ?? ''),
    );
  }

  static String _bestThumbnail(Object? thumbnails) {
    if (thumbnails is! Map) return '';
    final map = Map<String, dynamic>.from(thumbnails);
    for (final key in ['maxres', 'standard', 'high', 'medium', 'default']) {
      final entry = map[key];
      if (entry is Map && entry['url'] is String) {
        return entry['url'] as String;
      }
    }
    return '';
  }

  /// Parses ISO-8601 duration (`PT1H2M3S`) into `h:mm:ss` / `m:ss`.
  static String formatIso8601Duration(String iso) {
    if (iso.isEmpty) return '';
    final match = RegExp(
      r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$',
    ).firstMatch(iso);
    if (match == null) return '';
    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '') ?? 0;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class YoutubeChannelMeta {
  const YoutubeChannelMeta({
    required this.id,
    required this.title,
    required this.uploadsPlaylistId,
  });

  final String id;
  final String title;
  final String uploadsPlaylistId;

  factory YoutubeChannelMeta.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final snippet = json['snippet'] is Map
        ? Map<String, dynamic>.from(json['snippet'] as Map)
        : const <String, dynamic>{};
    final content = json['contentDetails'] is Map
        ? Map<String, dynamic>.from(json['contentDetails'] as Map)
        : const <String, dynamic>{};
    final related = content['relatedPlaylists'] is Map
        ? Map<String, dynamic>.from(content['relatedPlaylists'] as Map)
        : const <String, dynamic>{};
    return YoutubeChannelMeta(
      id: id,
      title: snippet['title'] as String? ?? '',
      uploadsPlaylistId: related['uploads'] as String? ?? '',
    );
  }
}
