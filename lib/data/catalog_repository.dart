import 'mock_catalog.dart';
import 'models/curated_channel.dart';
import 'models/shelf.dart';
import 'models/video_item.dart';
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
  })  : _api = api,
        _curated = curated;

  final YoutubeApiClient _api;
  final CuratedCatalogConfig _curated;
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

    List<VideoItem> fromCategory(String category) {
      final ids = ready
          .where((c) => c.category == category)
          .map((c) => c.channelId)
          .toSet();
      return all.where((v) => ids.contains(v.channelId)).take(12).toList();
    }

    final featuredIds = ready
        .where((c) => c.category == 'featured')
        .map((c) => c.channelId)
        .toSet();
    var featured = all.where((v) => featuredIds.contains(v.channelId)).take(8).toList();
    if (featured.isEmpty) {
      featured = all.take(8).toList();
    }

    final travel = fromCategory('travel');
    final food = fromCategory('food');
    final daily = fromCategory('daily');

    final shelves = <Shelf>[
      Shelf(id: 'featured', title: 'Featured', items: featured),
      Shelf(
        id: 'new',
        title: 'New from creators',
        items: all.take(12).toList(),
      ),
      if (travel.isNotEmpty) Shelf(id: 'travel', title: 'Travel', items: travel),
      if (food.isNotEmpty) Shelf(id: 'food', title: 'Food', items: food),
      if (daily.isNotEmpty)
        Shelf(id: 'daily', title: 'Daily life', items: daily),
      // Continue watching stays local/mock until watch history lands.
      Shelf(
        id: 'continue',
        title: 'Continue watching',
        items: MockCatalog.shelves
            .firstWhere(
              (s) => s.id == 'continue',
              orElse: () => const Shelf(id: 'continue', title: 'Continue watching', items: []),
            )
            .items,
      ),
    ];

    return shelves.where((s) => s.items.isNotEmpty).toList();
  }
}
