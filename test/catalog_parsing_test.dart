import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/curated_channels_loader.dart';
import 'package:monvlog/data/models/curated_channel.dart';
import 'package:monvlog/data/youtube/youtube_api_client.dart';

void main() {
  group('CuratedChannelsLoader.parseJsonString', () {
    test('parses channels and separates stubs from api-ready IDs', () {
      const raw = '''
{
  "version": 1,
  "source": "test",
  "channels": [
    {
      "channelId": "UCQXxhQHalYjwMictp1lUbtg",
      "handle": "@GremixBn",
      "displayName": "Gremix",
      "category": "daily",
      "verified": true
    },
    {
      "channelId": "UC________________STUB01",
      "handle": "@REPLACE_me",
      "displayName": "Stub Channel",
      "category": "travel",
      "verified": false,
      "notes": "STUB — replace"
    }
  ]
}
''';
      final config = CuratedChannelsLoader.parseJsonString(raw);
      expect(config.version, 1);
      expect(config.channels, hasLength(2));
      expect(config.apiReady, hasLength(1));
      expect(config.apiReady.first.channelId, 'UCQXxhQHalYjwMictp1lUbtg');
      expect(config.channels.last.isStub, isTrue);
      expect(config.channels.last.notes, contains('STUB'));
    });

    test('CuratedChannel.fromJson defaults missing fields safely', () {
      final channel = CuratedChannel.fromJson(const {
        'channelId': 'UCabcdefghijklmnopqrstuv',
      });
      expect(channel.displayName, isEmpty);
      expect(channel.category, 'daily');
      expect(channel.verified, isFalse);
      expect(channel.isStub, isTrue);
    });

    test('rejects non-object roots', () {
      expect(
        () => CuratedChannelsLoader.parseJsonString('[]'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('YoutubeApiClient.formatIso8601Duration', () {
    test('formats hours, minutes, seconds', () {
      expect(YoutubeApiClient.formatIso8601Duration('PT1H2M3S'), '1:02:03');
      expect(YoutubeApiClient.formatIso8601Duration('PT15M4S'), '15:04');
      expect(YoutubeApiClient.formatIso8601Duration('PT45S'), '0:45');
      expect(YoutubeApiClient.formatIso8601Duration(''), '');
      expect(YoutubeApiClient.formatIso8601Duration('bogus'), '');
    });
  });
}
