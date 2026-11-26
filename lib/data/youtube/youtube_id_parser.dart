/// Parsed YouTube channel URL / ID (UC, @handle, /c/, /user/, vanity).
enum YoutubeChannelRefKind {
  /// Canonical `UC…` channel id (`/channel/UC…` or bare).
  channelId,

  /// Handle without leading `@` (`/@name`).
  handle,

  /// Legacy custom URL slug (`/c/name`).
  customUrl,

  /// Legacy username (`/user/name`).
  username,

  /// Legacy vanity path (`youtube.com/orgiluuntv2` — single slug, not reserved).
  vanity,
}

/// A channel identifier extracted from a pasted URL or bare id/handle.
class YoutubeChannelRef {
  const YoutubeChannelRef({
    required this.kind,
    required this.value,
  });

  final YoutubeChannelRefKind kind;

  /// Raw value: `UC…`, handle without `@`, or `/c`/`/user`/vanity slug.
  final String value;

  bool get isChannelId => kind == YoutubeChannelRefKind.channelId;

  /// True when YouTube Data API (or a public-page scrape) is required to map to a UC id.
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
      case YoutubeChannelRefKind.vanity:
        return '/$value';
    }
  }

  /// Public youtube.com path used for optional no-key page scrape.
  String get publicPath {
    switch (kind) {
      case YoutubeChannelRefKind.channelId:
        return '/channel/$value';
      case YoutubeChannelRefKind.handle:
        return '/@$value';
      case YoutubeChannelRefKind.customUrl:
        return '/c/$value';
      case YoutubeChannelRefKind.username:
        return '/user/$value';
      case YoutubeChannelRefKind.vanity:
        return '/$value';
    }
  }
}

/// Parses YouTube playlist / channel identifiers from URLs or bare IDs.
class YoutubeIdParser {
  YoutubeIdParser._();

  /// Path segments that are never legacy vanity channel slugs.
  static const Set<String> _reservedPathSegments = {
    'watch',
    'playlist',
    'feed',
    'results',
    'shorts',
    'live',
    'gaming',
    'premium',
    'account',
    'about',
    'upload',
    'embed',
    'redirect',
    'signin',
    'signup',
    'logout',
    'pair',
    'tv',
    'kids',
    'music',
    'channel',
    'c',
    'user',
    'hashtag',
    'post',
    'clip',
    'attribution_link',
    'oembed',
    'iframe_api',
    's',
    't',
    'timedtext',
    'api',
    'youtubei',
    'img',
    'yts',
    'howyoutubeworks',
    'trends',
    'reporthistory',
    'podcasts',
    'studio',
    'ads',
    'creators',
    'intl',
    'error',
    'unsupported_browse',
    'index',
    'share',
    'redirector',
  };

  /// Playlist ID from a URL (`?list=` / `/playlist?list=`) or a bare ID
  /// (`PL…`, `UU…`, `OL…`, `LL…`, `RD…`, `FL…`).
  static String? parsePlaylistId(String input) {
    final raw = _normalizePaste(input);
    if (raw.isEmpty) return null;

    final uri = _tryParseYoutubeUri(raw) ?? Uri.tryParse(raw);
    if (uri != null &&
        (uri.hasScheme ||
            raw.contains('youtube') ||
            raw.contains('youtu.be'))) {
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
  /// Prefer [parseChannelRef] when `@handle` / `/c/` / `/user/` / vanity must be kept.
  static String? parseChannelId(String input) {
    final ref = parseChannelRef(input);
    if (ref == null || ref.kind != YoutubeChannelRefKind.channelId) return null;
    return ref.value;
  }

  /// Channel ref from `/@handle`, `/channel/UC…`, `/c/…`, `/user/…`,
  /// legacy vanity `youtube.com/{slug}`, `?channel_id=`, bare `UC…`, or bare `@handle`.
  ///
  /// Accepts missing `https://`, strips share junk (`si=`, `feature=`, …) by
  /// reading path / known id params only, and pulls the first youtube.com URL
  /// out of messy paste text.
  static YoutubeChannelRef? parseChannelRef(String input) {
    final raw = _normalizePaste(input);
    if (raw.isEmpty) return null;

    // Bare @handle (no URL).
    if (raw.startsWith('@') && raw.length > 1 && !raw.contains('/')) {
      final handle = raw.substring(1).split(RegExp(r'[?#\s]')).first.trim();
      if (_looksLikeHandle(handle)) {
        return YoutubeChannelRef(
          kind: YoutubeChannelRefKind.handle,
          value: handle,
        );
      }
    }

    // Bare UC id (ignore trailing query/share junk if pasted after the id).
    final bareId = raw.split(RegExp(r'[?#\s&]')).first.trim();
    if (_looksLikeChannelId(bareId)) {
      return YoutubeChannelRef(
        kind: YoutubeChannelRefKind.channelId,
        value: bareId,
      );
    }

    final extracted = _extractYoutubeUrlCandidate(raw) ?? raw;
    final uri = _tryParseYoutubeUri(extracted);
    if (uri == null) return null;
    if (!_isYoutubeHost(uri.host) && !extracted.startsWith('/')) {
      return null;
    }

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
        final handle = seg.substring(1).split(RegExp(r'[?#]')).first;
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
        final slug = segments[i + 1].split(RegExp(r'[?#]')).first;
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
        final slug = segments[i + 1].split(RegExp(r'[?#]')).first;
        if (_looksLikeSlug(slug)) {
          return YoutubeChannelRef(
            kind: YoutubeChannelRefKind.username,
            value: slug,
          );
        }
      }
    }

    // Legacy vanity: youtube.com/{slug} (e.g. youtube.com/orgiluuntv2?si=…)
    if (segments.length == 1) {
      final slug = segments.first.split(RegExp(r'[?#]')).first;
      final lower = slug.toLowerCase();
      if (!_reservedPathSegments.contains(lower) &&
          !slug.startsWith('@') &&
          _looksLikeSlug(slug)) {
        return YoutubeChannelRef(
          kind: YoutubeChannelRefKind.vanity,
          value: slug,
        );
      }
    }

    return null;
  }

  /// Trim, unwrap quotes, take first non-empty line.
  static String _normalizePaste(String input) {
    var text = input.trim();
    if (text.isEmpty) return '';
    text = text.replaceAll(RegExp(r'''^["'`]+|["'`]+$'''), '').trim();
    final line = text
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');
    return line;
  }

  /// Pull the first youtube.com / m.youtube.com URL-like token from messy paste.
  static String? _extractYoutubeUrlCandidate(String raw) {
    final match = RegExp(
      r'''(?:https?://)?(?:www\.)?(?:m\.)?youtube\.com/[^\s"'<>]+''',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) return null;
    // Drop trailing punctuation often left by messengers.
    return match.group(0)!.replaceAll(RegExp(r'''[.,;:!?)\]]+$'''), '');
  }

  static bool _isYoutubeHost(String host) {
    final h = host.toLowerCase();
    return h == 'youtube.com' ||
        h == 'www.youtube.com' ||
        h == 'm.youtube.com' ||
        h.endsWith('.youtube.com');
  }

  static Uri? _tryParseYoutubeUri(String raw) {
    if (raw.startsWith('/')) {
      return Uri.tryParse('https://www.youtube.com$raw');
    }
    var text = raw.trim();
    if (!text.contains('://') &&
        (text.toLowerCase().contains('youtube.com') ||
            text.toLowerCase().contains('youtu.be') ||
            text.toLowerCase().contains('m.youtube.com'))) {
      text = 'https://$text';
    }
    final uri = Uri.tryParse(text);
    if (uri == null) return null;
    // Path-only parsing ignores query junk (si=, feature=, …).
    return uri;
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
