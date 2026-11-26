import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/catalog_repository.dart';
import 'package:monvlog/data/catalog_store.dart';
import 'package:monvlog/data/models/curated_channel.dart';
import 'package:monvlog/data/youtube/youtube_api_client.dart';

void main() {
  test('loadChannelCatalog returns mock shelves without API key', () async {
    final repo = CatalogRepository(
      api: YoutubeApiClient(apiKey: ''),
      curated: const CuratedCatalogConfig(
        version: 1,
        channels: [
          CuratedChannel(
            channelId: 'UCQXxhQHalYjwMictp1lUbtg',
            displayName: 'Gremix',
            category: 'daily',
            verified: true,
          ),
        ],
      ),
      playlists: const [
        CuratedPlaylist(
          playlistId: 'PLmonvlog_europe_tour_mock',
          title: 'Europe Tour Highlights',
          channelId: 'UCQXxhQHalYjwMictp1lUbtg',
          channelName: 'Gremix',
        ),
      ],
    );

    final snap = await repo.loadChannelCatalog('UCQXxhQHalYjwMictp1lUbtg');
    expect(snap.isMock, isTrue);
    expect(snap.channel.displayName, 'Gremix');
    expect(snap.shelves, isNotEmpty);
    expect(snap.shelves.any((s) => s.id == 'uploads'), isTrue);
    expect(
      snap.shelves.any((s) => s.id == 'playlist_PLmonvlog_europe_tour_mock'),
      isTrue,
    );
    expect(snap.shelves.first.items, isNotEmpty);
  });

  test('getPlaylist returns mock meta without API key', () async {
    final api = YoutubeApiClient(apiKey: '');
    final meta = await api.getPlaylist('PLmonvlog_europe_tour_mock');
    expect(meta, isNotNull);
    expect(meta!.isMock, isTrue);
    expect(meta.id, 'PLmonvlog_europe_tour_mock');
    expect(meta.title, contains('PLmonvlog_europe_tour_mock'));
  });
}
