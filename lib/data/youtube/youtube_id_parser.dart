/// Parsed YouTube channel URL / ID (UC, @handle, /c/, /user/).
enum YoutubeChannelRefKind {
  /// Canonical `UC…` channel id (`/channel/UC…` or bare).
  channelId,

  /// Handle without leading `@` (`/@name`).
  handle,

  /// Legacy custom URL slug (`/c/name`).
  customUrl,

  /// Legacy username (`/user/name`).
  username,
}

/// A channel identifier extracted from a pasted URL or bare id/handle.
class YoutubeChannelRef {
  const YoutubeChannelRef({
    required this.kind,
    required this.value,
  });

  final YoutubeChannelRefKind kind;

  /// Raw value: `UC…`, handle without `@`, or `/c`/`/user` slug.
  final String value;

  bool get isChannelId => kind == YoutubeChannelRefKind.channelId;

  /// True when YouTube Data API is required to map to a UC id.
  bool get requiresApiLookup => kind != YoutubeChannelRefKind.channelId;

  String get displayLabel {
    switch (kind) {
      case YoutubeChannelRefKind.channelId:
        return value;
      case YoutubeChannelRefKind.handle:
        return '@$value';
      case YoutubeChannelRefKind.customUrl:
        return '/c/$value';
      case YoutubeChannelRefKind.username:
        return '/user/$value';
    }
  }
}

/// Parses YouTube playlist / channel identifiers from URLs or bare IDs.
class YoutubeIdParser {
  YoutubeIdParser._();

  /// Playlist ID from a URL (`?list=` / `/playlist?list=`) or a bare ID
  /// (`PL…`, `UU…`, `OL…`, `LL…`, `RD…`, `FL…`).
  static String? parsePlaylistId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri != null &&
        (uri.hasScheme || raw.contains('youtube') || raw.contains('youtu.be'))) {
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
  /// Prefer [parseChannelRef] when `@handle` / `/c/` / `/user/` must be kept.
  static String? parseChannelId(String input) {
    final ref = parseChannelRef(input);
    if (ref == null || ref.kind != YoutubeChannelRefKind.channelId) return null;
    return ref.value;
  }

  /// Channel ref from `/@handle`, `/channel/UC…`, `/c/…`, `/user/…`,
  /// `?channel_id=`, bare `UC…`, or bare `@handle`.
  static YoutubeChannelRef? parseChannelRef(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    // Bare @handle (no URL).
    if (raw.startsWith('@') && raw.length > 1 && !raw.contains('/')) {
      final handle = raw.substring(1).trim();
      if (_looksLikeHandle(handle)) {
        return YoutubeChannelRef(
          kind: YoutubeChannelRefKind.handle,
          value: handle,
        );
      }
    }

    // Bare UC id.
    if (_looksLikeChannelId(raw)) {
      return YoutubeChannelRef(
        kind: YoutubeChannelRefKind.channelId,
        value: raw,
      );
    }

    final uri = _tryParseYoutubeUri(raw);
    if (uri == null) return null;

    final channelIdParam = uri.queryParameters['channel_id']?.trim();
    if (channelIdParam != null && _looksLikeChannelId(channelIdParam)) {
      return YoutubeChannelRef(
        kind: YoutubeChannelRefKind.channelId,
        value: channelIdParam,
      );
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    // /channel/UC…
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i].toLowerCase() == 'channel' &&
          _looksLikeChannelId(segments[i + 1])) {
        return YoutubeChannelRef(
          kind: YoutubeChannelRefKind.channelId,
          value: segments[i + 1],
        );
      }
    }

    // /@handle (path segment may be "@handle")
    for (final seg in segments) {
      if (seg.startsWith('@') && seg.length > 1) {
        final handle = seg.substring(1);
        if (_looksLikeHandle(handle)) {
          return YoutubeChannelRef(
            kind: YoutubeChannelRefKind.handle,
            value: handle,
          );
        }
      }
    }

    // /c/customName
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i].toLowerCase() == 'c') {
        final slug = segments[i + 1];
        if (_looksLikeSlug(slug)) {
          return YoutubeChannelRef(
            kind: YoutubeChannelRefKind.customUrl,
            value: slug,
          );
        }
      }
    }

    // /user/username
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i].toLowerCase() == 'user') {
        final slug = segments[i + 1];
        if (_looksLikeSlug(slug)) {
          return YoutubeChannelRef(
            kind: YoutubeChannelRefKind.username,
            value: slug,
          );
        }
      }
    }

    return null;
  }

  static Uri? _tryParseYoutubeUri(String raw) {
    if (raw.startsWith('/')) {
      return Uri.tryParse('https://www.youtube.com$raw');
    }
    var text = raw;
    if (!text.contains('://') &&
        (text.contains('youtube.com') ||
            text.contains('youtu.be') ||
            text.contains('m.youtube.com'))) {
      text = 'https://$text';
    }
    return Uri.tryParse(text);
  }

  static bool _looksLikePlaylistId(String id) {
    // YouTube playlist ids are typically 13–64 chars: PL / UU / OL / LL / RD / FL…
    if (id.length < 10 || id.length > 80) return false;
    return RegExp(r'^(PL|UU|OL|LL|RD|FL)[A-Za-z0-9_-]+$').hasMatch(id);
  }

  static bool _looksLikeChannelId(String id) {
    return RegExp(r'^UC[A-Za-z0-9_-]{20,}$').hasMatch(id);
  }

  static bool _looksLikeHandle(String handle) {
    if (handle.isEmpty || handle.length > 30) return false;
    return RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(handle);
  }

  static bool _looksLikeSlug(String slug) {
    if (slug.isEmpty || slug.length > 100) return false;
    return RegExp(r'^[A-Za-z0-9._%-]+$').hasMatch(slug);
  }
}
