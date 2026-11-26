/// Parses YouTube playlist / channel identifiers from URLs or bare IDs.
class YoutubeIdParser {
  YoutubeIdParser._();

  /// Playlist ID from a URL (`?list=` / `/playlist?list=`) or a bare ID
  /// (`PL…`, `UU…`, `OL…`, `LL…`, `RD…`, `FL…`).
  static String? parsePlaylistId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri != null && (uri.hasScheme || raw.contains('youtube') || raw.contains('youtu.be'))) {
      final list = uri.queryParameters['list']?.trim();
      if (list != null && list.isNotEmpty && _looksLikePlaylistId(list)) {
        return list;
      }
    }

    // Bare ID (optionally wrapped in whitespace / quotes).
    final bare = raw
        .replaceAll(RegExp(r'''^["']+|["']+$'''), '')
        .split(RegExp(r'\s+'))
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (_looksLikePlaylistId(bare)) return bare;
    return null;
  }

  /// Channel UC ID from `/channel/UC…`, `?channel_id=`, or a bare `UC…` id.
  static String? parseChannelId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      for (var i = 0; i < segments.length - 1; i++) {
        if (segments[i].toLowerCase() == 'channel' &&
            _looksLikeChannelId(segments[i + 1])) {
          return segments[i + 1];
        }
      }
      final channelId = uri.queryParameters['channel_id']?.trim();
      if (channelId != null && _looksLikeChannelId(channelId)) {
        return channelId;
      }
    }

    if (_looksLikeChannelId(raw)) return raw;
    return null;
  }

  static bool _looksLikePlaylistId(String id) {
    // YouTube playlist ids are typically 13–64 chars: PL / UU / OL / LL / RD / FL…
    if (id.length < 10 || id.length > 80) return false;
    return RegExp(r'^(PL|UU|OL|LL|RD|FL)[A-Za-z0-9_-]+$').hasMatch(id);
  }

  static bool _looksLikeChannelId(String id) {
    return RegExp(r'^UC[A-Za-z0-9_-]{20,}$').hasMatch(id);
  }
}
