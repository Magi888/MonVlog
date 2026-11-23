import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/youtube/youtube_api_client.dart';

void main() {
  test('searchChannelsByName returns mock hits when API key missing', () async {
    final api = YoutubeApiClient(apiKey: '');
    expect(api.isConfigured, isFalse);

    final result = await api.searchChannelsByName('Tselmeg');
    expect(result.isMock, isTrue);
    expect(result.message, contains('YOUTUBE_API_KEY'));
    expect(result.hits, isNotEmpty);
    expect(
      result.hits.any((h) => h.title.toLowerCase().contains('tselmeg')),
      isTrue,
    );
    expect(result.hits.every((h) => h.isMock), isTrue);
  });

  test('empty query returns no hits', () async {
    final api = YoutubeApiClient(apiKey: '');
    final result = await api.searchChannelsByName('  ');
    expect(result.hits, isEmpty);
    expect(result.isMock, isFalse);
  });
}
