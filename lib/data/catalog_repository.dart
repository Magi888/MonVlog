import 'catalog_store.dart';
import 'mock_catalog.dart';
import 'models/curated_channel.dart';
import 'models/shelf.dart';
import 'models/video_item.dart';
import 'shelf_categorizer.dart';
import 'youtube/youtube_api_client.dart';

enum CatalogSource { live, mock }

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.shelves,
    required this.source,
    required this.channels,
    this.message = '',
  });

  final List<Shelf> shelves;
  final CatalogSource source;
  final List<CuratedChannel> channels;
  final String message;

  bool get isMock => source == CatalogSource.mock;
}

/// One curated channel opened for browse/watch (uploads + linked playlists).
class ChannelCatalogSnapshot {
  const ChannelCatalogSnapshot({
    required this.channel,
    required this.shelves,
    required this.source,
    this.message = '',
    this.thumbnailUrl = '',
    this.description = '',
  });

  final CuratedChannel channel;
  final List<Shelf> shelves;
  final CatalogSource source;
  final String message;
  final String thumbnailUrl;
  final String description;

  bool get isMock => source == CatalogSource.mock;
}

/// Builds home shelves from YouTube Data API, with graceful mock fallback.
class CatalogRepository {
  CatalogRepository({
    required YoutubeApiClient api,
    required CuratedCatalogConfig curated,
    List<CuratedPlaylist> playlists = const [],
    this.perChannelUploads = 4,
    this.channelUploads = 24,
    ShelfCategorizer categorizer = const ShelfCategorizer(),
  })  : _api = api,
        _curated = curated,
        _playlists = playlists,
        _categorizer = categorizer;

  final YoutubeApiClient _api;
  final CuratedCatalogConfig _curated;
  final List<CuratedPlaylist> _playlists;
  final ShelfCategorizer _categorizer;
  final int perChannelUploads;
  final int channelUploads;

  CuratedCatalogConfig get curated => _curated;
  List<CuratedPlaylist> get playlists => _playlists;

  Future<CatalogSnapshot> loadHomeShelves() async {
    // [YoutubeApiClient] reads `--dart-define=YOUTUBE_API_KEY` by default.
    if (!_api.isConfigured) {
      return CatalogSnapshot(
        shelves: MockCatalog.shelves,
        source: CatalogSource.mock,
        channels: _curated.channels,
        message: 'YOUTUBE_API_KEY missing — showing mock catalog',
      );
    }

    final ready = _curated.apiReady;
    if (ready.isEmpty) {
      return CatalogSnapshot(
        shelves: MockCatalog.shelves,
        source: CatalogSource.mock,
        channels: _curated.channels,
        message: 'No verified channel IDs — showing mock catalog',
      );
    }

    try {
      final shelves = await _buildLiveShelves(ready);
      if (shelves.every((s) => s.items.isEmpty)) {
        return CatalogSnapshot(
          shelves: MockCatalog.shelves,
          source: CatalogSource.mock,
          channels: _curated.channels,
          message: 'YouTube returned no items — showing mock catalog',
        );
      }
      return CatalogSnapshot(
        shelves: shelves,
        source: CatalogSource.live,
        channels: _curated.channels,
        message: 'Live YouTube curated catalog',
      );
    } catch (e) {
      return CatalogSnapshot(
        shelves: MockCatalog.shelves,
        source: CatalogSource.mock,
        channels: _curated.channels,
        message: 'YouTube error ($e) — showing mock catalog',
      );
    }
  }

  Future<List<Shelf>> _buildLiveShelves(List<CuratedChannel> ready) async {
    // Batch channels.list (API allows up to 50 ids).
    final metas = <String, YoutubeChannelMeta>{};
    for (var i = 0; i < ready.length; i += 40) {
      final slice = ready.skip(i).take(40).map((c) => c.channelId).toList();
      for (final meta in await _api.listChannels(slice)) {
        metas[meta.id] = meta;
      }
    }

    final byChannel = <String, List<VideoItem>>{};
    for (final channel in ready) {
      final meta = metas[channel.channelId];
      List<VideoItem> uploads;
      if (meta != null) {
        uploads = await _api.listPlaylistItems(
          playlistId: meta.uploadsPlaylistId,
          channelId: channel.channelId,
          channelName: meta.title.isNotEmpty ? meta.title : channel.displayName,
          maxResults: perChannelUploads,
        );
      } else {
        // Fallback path: search.list constrained to allowlisted channelId.
        uploads = await _api.searchByChannel(
          channelId: channel.channelId,
          channelName: channel.displayName,
          maxResults: perChannelUploads,
        );
      }
      if (uploads.isNotEmpty) {
        byChannel[channel.channelId] = await _api.enrichVideos(uploads);
      }
    }

    final all = byChannel.values.expand((e) => e).toList()
      ..sort((a, b) {
        final ap = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bp = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bp.compareTo(ap);
      });

    final channelCategory = {
      for (final c in ready) c.channelId: c.category,
    };

    List<VideoItem> forShelf(String shelfId) {
      final matched = <VideoItem>[];
      for (final v in all) {
        final channelCat = channelCategory[v.channelId] ?? ShelfTypes.daily;
        // Prefer video-title heuristics; fall back to curated channel category.
        final videoCat = _categorizer.categorizeVideo(
          v,
          fallback: channelCat,
        );
        final effective =
            videoCat != ShelfTypes.daily || channelCat == ShelfTypes.daily
                ? videoCat
                : channelCat;
        if (shelfId == ShelfTypes.featured) {
          if (channelCat == ShelfTypes.featured ||
              videoCat == ShelfTypes.featured) {
            matched.add(v);
          }
        } else if (effective == shelfId || channelCat == shelfId) {
          matched.add(v);
        }
      }
      return matched.take(12).toList();
    }

    var featured = forShelf(ShelfTypes.featured).take(8).toList();
    if (featured.isEmpty) {
      featured = all.take(8).toList();
    }

    final travel = forShelf(ShelfTypes.travel);
    final food = forShelf(ShelfTypes.food);
    final daily = forShelf(ShelfTypes.daily);

    final shelves = <Shelf>[
      Shelf(
        id: ShelfTypes.featured,
        title: ShelfTypes.displayTitle(ShelfTypes.featured),
        items: featured,
      ),
      Shelf(
        id: 'new',
        title: 'New from creators',
        items: all.take(12).toList(),
      ),
      if (travel.isNotEmpty)
        Shelf(
          id: ShelfTypes.travel,
          title: ShelfTypes.displayTitle(ShelfTypes.travel),
          items: travel,
        ),
      if (food.isNotEmpty)
        Shelf(
          id: ShelfTypes.food,
          title: ShelfTypes.displayTitle(ShelfTypes.food),
          items: food,
        ),
      if (daily.isNotEmpty)
        Shelf(
          id: ShelfTypes.daily,
          title: ShelfTypes.displayTitle(ShelfTypes.daily),
          items: daily,
        ),
      // Continue watching stays local/mock until watch history lands.
      Shelf(
        id: 'continue',
        title: 'Continue watching',
        items: MockCatalog.shelves
            .firstWhere(
              (s) => s.id == 'continue',
              orElse: () => const Shelf(
                id: 'continue',
                title: 'Continue watching',
                items: [],
              ),
            )
            .items,
      ),
    ];

    // Admin-linked playlists surface as extra home shelves (live items only).
    for (final playlist in _playlists) {
      if (playlist.playlistId.isEmpty) continue;
      try {
        final items = await _api.listPlaylistItems(
          playlistId: playlist.playlistId,
          channelId: playlist.channelId,
          channelName: playlist.channelName.isNotEmpty
              ? playlist.channelName
              : playlist.title,
          maxResults: 8,
        );
        if (items.isEmpty) continue;
        shelves.add(
          Shelf(
            id: 'playlist_${playlist.playlistId}',
            title: playlist.title,
            items: await _api.enrichVideos(items),
          ),
        );
      } catch (_) {
        // Skip broken playlist links; home still works from channel uploads.
      }
    }

    return shelves.where((s) => s.items.isNotEmpty).toList();
  }

  /// Browse a single channel: recent uploads + any admin-linked playlists.
  Future<ChannelCatalogSnapshot> loadChannelCatalog(String channelId) async {
    final id = channelId.trim();
    CuratedChannel? curated;
    for (final c in _curated.channels) {
      if (c.channelId == id) {
        curated = c;
        break;
      }
    }
    final channel = curated ??
        CuratedChannel(
          channelId: id,
          displayName: id.isEmpty ? 'Channel' : id,
          category: ShelfTypes.daily,
          verified: id.startsWith('UC') && !id.contains('STUB'),
        );

    if (id.isEmpty) {
      return ChannelCatalogSnapshot(
        channel: channel,
        shelves: const [],
        source: CatalogSource.mock,
        message: 'Missing channel id',
      );
    }

    final linked = _playlists.where((p) => p.channelId == id).toList();

    if (!_api.isConfigured || channel.isStub) {
      return ChannelCatalogSnapshot(
        channel: channel,
        shelves: _mockChannelShelves(channel, linked),
        source: CatalogSource.mock,
        message: !_api.isConfigured
            ? 'YOUTUBE_API_KEY missing — showing mock channel shelves'
            : 'Stub channel — showing mock shelves',
        thumbnailUrl:
            'https://picsum.photos/seed/${channel.channelId.hashCode}/640/360',
      );
    }

    try {
      final metas = await _api.listChannels([id]);
      final meta = metas.isNotEmpty ? metas.first : null;
      final displayName = (meta?.title.isNotEmpty == true)
          ? meta!.title
          : channel.displayName;

      final shelves = <Shelf>[];
      if (meta != null && meta.uploadsPlaylistId.isNotEmpty) {
        final uploads = await _api.listPlaylistItems(
          playlistId: meta.uploadsPlaylistId,
          channelId: id,
          channelName: displayName,
          maxResults: channelUploads,
        );
        if (uploads.isNotEmpty) {
          shelves.add(
            Shelf(
              id: 'uploads',
              title: 'Latest uploads',
              items: await _api.enrichVideos(uploads),
            ),
          );
        }
      } else {
        final search = await _api.searchByChannel(
          channelId: id,
          channelName: displayName,
          maxResults: channelUploads,
        );
        if (search.isNotEmpty) {
          shelves.add(
            Shelf(
              id: 'uploads',
              title: 'Latest uploads',
              items: await _api.enrichVideos(search),
            ),
          );
        }
      }

      for (final playlist in linked) {
        final items = await _api.listPlaylistItems(
          playlistId: playlist.playlistId,
          channelId: id,
          channelName: displayName,
          maxResults: 16,
        );
        if (items.isEmpty) continue;
        shelves.add(
          Shelf(
            id: 'playlist_${playlist.playlistId}',
            title: playlist.title,
            items: await _api.enrichVideos(items),
          ),
        );
      }

      if (shelves.every((s) => s.items.isEmpty)) {
        return ChannelCatalogSnapshot(
          channel: channel.copyWithDisplayName(displayName),
          shelves: _mockChannelShelves(channel, linked),
          source: CatalogSource.mock,
          message: 'YouTube returned no items — showing mock channel shelves',
          thumbnailUrl: meta?.thumbnailUrl ?? '',
          description: meta?.description ?? '',
        );
      }

      return ChannelCatalogSnapshot(
        channel: channel.copyWithDisplayName(displayName),
        shelves: shelves,
        source: CatalogSource.live,
        message: 'Live channel catalog',
        thumbnailUrl: meta?.thumbnailUrl ?? '',
        description: meta?.description ?? '',
      );
    } catch (e) {
      return ChannelCatalogSnapshot(
        channel: channel,
        shelves: _mockChannelShelves(channel, linked),
        source: CatalogSource.mock,
        message: 'YouTube error ($e) — showing mock channel shelves',
      );
    }
  }

  List<Shelf> _mockChannelShelves(
    CuratedChannel channel,
    List<CuratedPlaylist> linked,
  ) {
    final seed = channel.channelId.hashCode.abs();
    final name = channel.displayName.isNotEmpty
        ? channel.displayName
        : 'Creator';
    final uploads = List<VideoItem>.generate(6, (i) {
      final n = seed + i;
      return VideoItem(
        id: 'mock_ch_${channel.channelId}_$i',
        title: '$name · episode ${i + 1}',
        channelName: name,
        channelId: channel.channelId,
        thumbnailUrl: 'https://picsum.photos/seed/ch$n/480/270',
        durationLabel: '${8 + i}:${(i * 7 % 60).toString().padLeft(2, '0')}',
        description: 'Mock upload for $name (offline / no API key).',
      );
    });

    final shelves = <Shelf>[
      Shelf(id: 'uploads', title: 'Latest uploads', items: uploads),
    ];
    for (final playlist in linked) {
      shelves.add(
        Shelf(
          id: 'playlist_${playlist.playlistId}',
          title: playlist.title,
          items: List<VideoItem>.generate(4, (i) {
            final n = playlist.playlistId.hashCode.abs() + i;
            return VideoItem(
              id: 'mock_pl_${playlist.playlistId}_$i',
              title: '${playlist.title} · ${i + 1}',
              channelName: name,
              channelId: channel.channelId,
              thumbnailUrl: 'https://picsum.photos/seed/pl$n/480/270',
              durationLabel: '${5 + i}:0${i % 10}',
              description: 'Mock playlist item for ${playlist.title}.',
            );
          }),
        ),
      );
    }
    return shelves;
  }
}

extension on CuratedChannel {
  CuratedChannel copyWithDisplayName(String displayName) {
    if (displayName.isEmpty || displayName == this.displayName) return this;
    return CuratedChannel(
      channelId: channelId,
      displayName: displayName,
      category: category,
      verified: verified,
      handle: handle,
      notes: notes,
    );
  }
}
