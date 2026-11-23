import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/catalog_store.dart';
import 'package:monvlog/data/curated_channels_loader.dart';
import 'package:monvlog/data/shelf_categorizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addChannel persists locally and auto-categorizes travel', () async {
    final store = CatalogStore(
      loader: CuratedChannelsLoader(
        bundle: _FakeBundle(_minimalCatalogJson),
      ),
    );

    final channel = await store.addChannel(
      channelId: 'UCabcdefghijklmnopqrstuv',
      displayName: 'Nomad Travel Diary',
      descriptionForHeuristic: 'Europe tour road trip adventure',
    );

    expect(channel.category, ShelfTypes.travel);
    expect(channel.verified, isTrue);

    final local = await store.loadLocalChannels();
    expect(local, hasLength(1));
    expect(local.first.channelId, channel.channelId);

    final merged = await store.loadMerged();
    expect(
      merged.channels.any((c) => c.channelId == channel.channelId),
      isTrue,
    );
    expect(merged.source, contains('local'));
  });

  test('addPlaylist stores remote-ready entry', () async {
    final store = CatalogStore(
      loader: CuratedChannelsLoader(
        bundle: _FakeBundle(_minimalCatalogJson),
      ),
    );

    final playlist = await store.addPlaylist(
      playlistId: 'PLtest123',
      title: 'Cooking Week',
      channelId: 'UCabcdefghijklmnopqrstuv',
      channelName: 'Chef',
    );

    expect(playlist.category, ShelfTypes.food);
    final list = await store.loadLocalPlaylists();
    expect(list, hasLength(1));

    final export = await store.exportRemoteReadyJson();
    expect(export['playlists'], isA<List>());
    expect((export['playlists'] as List), hasLength(1));
    expect(export['channels'], isA<List>());
  });
}

const _minimalCatalogJson = '''
{
  "version": 1,
  "source": "test",
  "channels": [
    {
      "channelId": "UCQXxhQHalYjwMictp1lUbtg",
      "displayName": "Gremix",
      "category": "daily",
      "verified": true
    }
  ]
}
''';

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.json);

  final String json;

  @override
  Future<ByteData> load(String key) async {
    final bytes = ByteData.view(
      Uint8List.fromList(json.codeUnits).buffer,
    );
    return bytes;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => json;
}
