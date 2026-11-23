import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/catalog_repository.dart';
import 'package:monvlog/data/mock_catalog.dart';
import 'package:monvlog/data/models/curated_channel.dart';
import 'package:monvlog/data/youtube/youtube_api_client.dart';

class _FailingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      message: 'simulated network failure',
      type: DioExceptionType.connectionError,
    );
  }
}

void main() {
  final curated = CuratedCatalogConfig(
    version: 1,
    channels: const [
      CuratedChannel(
        channelId: 'UCQXxhQHalYjwMictp1lUbtg',
        displayName: 'Gremix',
        category: 'daily',
        verified: true,
      ),
      CuratedChannel(
        channelId: 'UC________________STUB01',
        displayName: 'Stub',
        category: 'travel',
        verified: false,
      ),
    ],
  );

  test('falls back to mock when API key is missing', () async {
    final api = YoutubeApiClient(apiKey: '');
    final repo = CatalogRepository(api: api, curated: curated);

    final snapshot = await repo.loadHomeShelves();

    expect(snapshot.source, CatalogSource.mock);
    expect(snapshot.isMock, isTrue);
    expect(snapshot.shelves, MockCatalog.shelves);
    expect(snapshot.message.toLowerCase(), contains('youtube_api_key'));
    expect(snapshot.channels, hasLength(2));
  });

  test('falls back to mock when live YouTube request fails', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FailingAdapter();
    final api = YoutubeApiClient(dio: dio, apiKey: 'test-key-not-real');
    final repo = CatalogRepository(api: api, curated: curated);

    final snapshot = await repo.loadHomeShelves();

    expect(snapshot.source, CatalogSource.mock);
    expect(snapshot.shelves.first.id, MockCatalog.shelves.first.id);
    expect(snapshot.message.toLowerCase(), contains('youtube'));
  });

  test('falls back when curated list has only stubs', () async {
    final stubsOnly = CuratedCatalogConfig(
      version: 1,
      channels: const [
        CuratedChannel(
          channelId: 'UC________________STUB01',
          displayName: 'Stub',
          category: 'daily',
          verified: false,
        ),
      ],
    );
    final repo = CatalogRepository(
      api: YoutubeApiClient(apiKey: 'test-key-not-real'),
      curated: stubsOnly,
    );

    final snapshot = await repo.loadHomeShelves();
    expect(snapshot.source, CatalogSource.mock);
    expect(snapshot.message.toLowerCase(), contains('verified'));
  });
}
