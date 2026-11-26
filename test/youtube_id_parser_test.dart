import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/youtube/youtube_id_parser.dart';

void main() {
  group('parsePlaylistId', () {
    test('reads list query from playlist URL', () {
      expect(
        YoutubeIdParser.parsePlaylistId(
          'https://www.youtube.com/playlist?list=PLrAXtmRdnEQy6nuLMHjMZOz59Oq8P-8nN',
        ),
        'PLrAXtmRdnEQy6nuLMHjMZOz59Oq8P-8nN',
      );
    });

    test('reads list query from watch URL', () {
      expect(
        YoutubeIdParser.parsePlaylistId(
          'https://www.youtube.com/watch?v=abc123&list=PLmonvlog_europe_tour_mock',
        ),
        'PLmonvlog_europe_tour_mock',
      );
    });

    test('accepts bare playlist id', () {
      expect(
        YoutubeIdParser.parsePlaylistId('PLmonvlog_europe_tour_mock'),
        'PLmonvlog_europe_tour_mock',
      );
    });

    test('rejects empty / garbage', () {
      expect(YoutubeIdParser.parsePlaylistId(''), isNull);
      expect(YoutubeIdParser.parsePlaylistId('not-a-playlist'), isNull);
      expect(YoutubeIdParser.parsePlaylistId('UCQXxhQHalYjwMictp1lUbtg'), isNull);
    });
  });

  group('parseChannelId', () {
    test('reads /channel/UC path', () {
      expect(
        YoutubeIdParser.parseChannelId(
          'https://www.youtube.com/channel/UCQXxhQHalYjwMictp1lUbtg',
        ),
        'UCQXxhQHalYjwMictp1lUbtg',
      );
    });

    test('accepts bare UC id', () {
      expect(
        YoutubeIdParser.parseChannelId('UCQXxhQHalYjwMictp1lUbtg'),
        'UCQXxhQHalYjwMictp1lUbtg',
      );
    });
  });
}
