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

  test('resolveChannel requires API key for @handle without key', () async {
    final api = YoutubeApiClient(apiKey: '');
    final ref = YoutubeIdParser.parseChannelRef(
      'https://www.youtube.com/@TselmegVlog',
    )!;
    final result = await api.resolveChannel(ref);
    expect(result.isSuccess, isFalse);
    expect(result.needsApiKey, isTrue);
    expect(result.message, contains('YOUTUBE_API_KEY'));
  });

  test('resolveChannel requires API key for /c/ without key', () async {
    final api = YoutubeApiClient(apiKey: '');
    final ref = YoutubeIdParser.parseChannelRef(
      'https://www.youtube.com/c/PositiveMongolians',
    )!;
    final result = await api.resolveChannel(ref);
    expect(result.needsApiKey, isTrue);
  });
}
