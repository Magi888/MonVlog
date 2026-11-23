import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'curated_channels_loader.dart';
import 'models/curated_channel.dart';
import 'shelf_categorizer.dart';

/// Local curated-catalog overrides (admin additions) + merge with base asset /
/// remote JSON. Remote-ready: same shape as `assets/config/curated_channels.json`.
class CatalogStore {
  CatalogStore({
    CuratedChannelsLoader? loader,
    SharedPreferences? prefs,
    ShelfCategorizer categorizer = const ShelfCategorizer(),
  })  : _loader = loader ?? CuratedChannelsLoader(),
        _prefsOverride = prefs,
        _categorizer = categorizer;

  static const localOverridesKey = 'monvlog_catalog_local_overrides_v1';
  static const playlistsKey = 'monvlog_catalog_local_playlists_v1';

  final CuratedChannelsLoader _loader;
  final SharedPreferences? _prefsOverride;
  final ShelfCategorizer _categorizer;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _prefsOrGet() async {
    return _prefsOverride ?? (_prefs ??= await SharedPreferences.getInstance());
  }

  /// Base (asset/remote) + local admin overrides. Local wins on channelId clash.
  Future<CuratedCatalogConfig> loadMerged() async {
    final base = await _loader.load();
    final overrides = await loadLocalChannels();
    if (overrides.isEmpty) return base;

    final byId = <String, CuratedChannel>{
      for (final c in base.channels) c.channelId: c,
    };
    for (final c in overrides) {
      byId[c.channelId] = c;
    }
    return CuratedCatalogConfig(
      version: base.version,
      source: '${base.source}+local',
      channels: byId.values.toList(),
    );
  }

  Future<List<CuratedChannel>> loadLocalChannels() async {
    final prefs = await _prefsOrGet();
    final raw = prefs.getString(localOverridesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => CuratedChannel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CuratedPlaylist>> loadLocalPlaylists() async {
    final prefs = await _prefsOrGet();
    final raw = prefs.getString(playlistsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => CuratedPlaylist.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<CuratedChannel> addChannel({
    required String channelId,
    required String displayName,
    String handle = '',
    String notes = '',
    String? category,
    String? descriptionForHeuristic,
  }) async {
    final resolvedCategory = category?.trim().isNotEmpty == true
        ? category!.trim()
        : _categorizer.categorizeText(
            title: displayName,
            description: descriptionForHeuristic ?? '',
            keywords: handle.isEmpty ? const [] : [handle],
          );

    final channel = CuratedChannel(
      channelId: channelId,
      displayName: displayName,
      category: resolvedCategory,
      verified: channelId.startsWith('UC') && !channelId.contains('STUB'),
      handle: handle,
      notes: notes.isEmpty ? 'Added via admin catalog' : notes,
    );

    final existing = await loadLocalChannels();
    final next = [
      ...existing.where((c) => c.channelId != channel.channelId),
      channel,
    ];
    await _persistChannels(next);
    return channel;
  }

  Future<CuratedPlaylist> addPlaylist({
    required String playlistId,
    required String title,
    required String channelId,
    String channelName = '',
    String? category,
  }) async {
    final resolvedCategory = category?.trim().isNotEmpty == true
        ? category!.trim()
        : _categorizer.categorizeText(title: title, description: channelName);

    final playlist = CuratedPlaylist(
      playlistId: playlistId,
      title: title,
      channelId: channelId,
      channelName: channelName,
      category: resolvedCategory,
    );

    final existing = await loadLocalPlaylists();
    final next = [
      ...existing.where((p) => p.playlistId != playlist.playlistId),
      playlist,
    ];
    await _persistPlaylists(next);
    return playlist;
  }

  Future<void> removeChannel(String channelId) async {
    final existing = await loadLocalChannels();
    await _persistChannels(
      existing.where((c) => c.channelId != channelId).toList(),
    );
  }

  Future<void> _persistChannels(List<CuratedChannel> channels) async {
    final prefs = await _prefsOrGet();
    await prefs.setString(
      localOverridesKey,
      jsonEncode(channels.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> _persistPlaylists(List<CuratedPlaylist> playlists) async {
    final prefs = await _prefsOrGet();
    await prefs.setString(
      playlistsKey,
      jsonEncode(playlists.map((p) => p.toJson()).toList()),
    );
  }

  /// Export merged catalog JSON (remote-ready shape).
  Future<Map<String, dynamic>> exportRemoteReadyJson() async {
    final merged = await loadMerged();
    final playlists = await loadLocalPlaylists();
    return {
      'version': merged.version,
      'source': merged.source,
      'remoteUrlHint':
          'Optional override via --dart-define=CURATED_CHANNELS_URL=https://...',
      'channels': merged.channels.map((c) => c.toJson()).toList(),
      'playlists': playlists.map((p) => p.toJson()).toList(),
    };
  }
}

/// Curated playlist entry (admin-added).
class CuratedPlaylist {
  const CuratedPlaylist({
    required this.playlistId,
    required this.title,
    required this.channelId,
    this.channelName = '',
    this.category = ShelfTypes.daily,
  });

  final String playlistId;
  final String title;
  final String channelId;
  final String channelName;
  final String category;

  Map<String, dynamic> toJson() => {
        'playlistId': playlistId,
        'title': title,
        'channelId': channelId,
        'channelName': channelName,
        'category': category,
      };

  factory CuratedPlaylist.fromJson(Map<String, dynamic> json) {
    return CuratedPlaylist(
      playlistId: json['playlistId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      channelId: json['channelId'] as String? ?? '',
      channelName: json['channelName'] as String? ?? '',
      category: json['category'] as String? ?? ShelfTypes.daily,
    );
  }
}
