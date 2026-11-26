import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/youtube/youtube_api_client.dart';
import 'package:monvlog/data/youtube/youtube_id_parser.dart';

void main() {
  test('resolveChannel mocks UC id when API key missing', () async {
    final api = YoutubeApiClient(apiKey: '');
    final ref = YoutubeIdParser.parseChannelRef(
      'https://www.youtube.com/channel/UCQXxhQHalYjwMictp1lUbtg',
    )!;
    final result = await api.resolveChannel(ref);
    expect(result.isSuccess, isTrue);
    expect(result.needsApiKey, isFalse);
    expect(result.channel!.id, 'UCQXxhQHalYjwMictp1lUbtg');
    expect(result.channel!.isMock, isTrue);
  });

  test('resolveChannel requires API key for @handle without key when scrape fails',
      () async {
    final api = YoutubeApiClient(
      apiKey: '',
      scrapePublicChannelId: (_) async => null,
    );
    final ref = YoutubeIdParser.parseChannelRef(
      'https://www.youtube.com/@TselmegVlog',
    )!;
    final result = await api.resolveChannel(ref);
    expect(result.isSuccess, isFalse);
    expect(result.needsApiKey, isTrue);
    expect(result.message, contains('YOUTUBE_API_KEY'));
    expect(result.message, contains('/channel/UC'));
  });

  test('resolveChannel requires API key for /c/ without key when scrape fails',
      () async {
    final api = YoutubeApiClient(
      apiKey: '',
      scrapePublicChannelId: (_) async => null,
    );
    final ref = YoutubeIdParser.parseChannelRef(
      'https://www.youtube.com/c/PositiveMongolians',
    )!;
    final result = await api.resolveChannel(ref);
    expect(result.needsApiKey, isTrue);
  });

  test('resolveChannel uses scrape for vanity when API key missing', () async {
    const scraped = 'UCQXxhQHalYjwMictp1lUbtg';
    final api = YoutubeApiClient(
      apiKey: '',
      scrapePublicChannelId: (ref) async {
        expect(ref.kind, YoutubeChannelRefKind.vanity);
        expect(ref.value, 'orgiluuntv2');
        return scraped;
      },
    );
    final ref = YoutubeIdParser.parseChannelRef('youtube.com/orgiluuntv2?si=x')!;
    final result = await api.resolveChannel(ref);
    expect(result.isSuccess, isTrue);
    expect(result.needsApiKey, isFalse);
    expect(result.channel!.id, scraped);
    expect(result.channel!.isMock, isTrue);
  });

  test('resolveChannel vanity needs API key when scrape fails', () async {
    final api = YoutubeApiClient(
      apiKey: '',
      scrapePublicChannelId: (_) async => null,
    );
    final ref = YoutubeIdParser.parseChannelRef('youtube.com/orgiluuntv2')!;
    final result = await api.resolveChannel(ref);
    expect(result.needsApiKey, isTrue);
    expect(result.message.toLowerCase(), contains('vanity'));
  });
}
