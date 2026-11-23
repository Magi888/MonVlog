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

/// Builds home shelves from YouTube Data API, with graceful mock fallback.
class CatalogRepository {
  CatalogRepository({
    required YoutubeApiClient api,
    required CuratedCatalogConfig curated,
    this.perChannelUploads = 4,
    ShelfCategorizer categorizer = const ShelfCategorizer(),
  })  : _api = api,
        _curated = curated,
        _categorizer = categorizer;

  final YoutubeApiClient _api;
  final CuratedCatalogConfig _curated;
  final ShelfCategorizer _categorizer;
  final int perChannelUploads;

  CuratedCatalogConfig get curated => _curated;

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

    return shelves.where((s) => s.items.isNotEmpty).toList();
  }
}
