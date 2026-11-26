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

    test('does not treat @handle as channel id', () {
      expect(
        YoutubeIdParser.parseChannelId('https://www.youtube.com/@Gremix'),
        isNull,
      );
    });
  });

  group('parseChannelRef', () {
    test('parses /@handle URL', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://www.youtube.com/@TselmegVlog',
      );
      expect(ref, isNotNull);
      expect(ref!.kind, YoutubeChannelRefKind.handle);
      expect(ref.value, 'TselmegVlog');
      expect(ref.requiresApiLookup, isTrue);
    });

    test('parses youtube.com/@handle without scheme', () {
      final ref = YoutubeIdParser.parseChannelRef('youtube.com/@orgiluuntv2');
      expect(ref?.kind, YoutubeChannelRefKind.handle);
      expect(ref?.value, 'orgiluuntv2');
    });

    test('parses https://youtube.com/@handle', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://youtube.com/@Damisuna',
      );
      expect(ref?.kind, YoutubeChannelRefKind.handle);
      expect(ref?.value, 'Damisuna');
    });

    test('strips si= share junk from @handle URL', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'youtube.com/@TselmegVlog?si=AbCdEfGhIjKlMnOp',
      );
      expect(ref?.kind, YoutubeChannelRefKind.handle);
      expect(ref?.value, 'TselmegVlog');
    });

    test('parses bare @handle', () {
      final ref = YoutubeIdParser.parseChannelRef('@Gremix');
      expect(ref?.kind, YoutubeChannelRefKind.handle);
      expect(ref?.value, 'Gremix');
    });

    test('parses /channel/UC URL', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://youtube.com/channel/UCQXxhQHalYjwMictp1lUbtg',
      );
      expect(ref?.kind, YoutubeChannelRefKind.channelId);
      expect(ref?.value, 'UCQXxhQHalYjwMictp1lUbtg');
      expect(ref?.requiresApiLookup, isFalse);
    });

    test('strips si= from /channel/UC URL', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://www.youtube.com/channel/UCQXxhQHalYjwMictp1lUbtg?si=xyz',
      );
      expect(ref?.kind, YoutubeChannelRefKind.channelId);
      expect(ref?.value, 'UCQXxhQHalYjwMictp1lUbtg');
    });

    test('parses /c/ custom URL', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://www.youtube.com/c/PositiveMongolians',
      );
      expect(ref?.kind, YoutubeChannelRefKind.customUrl);
      expect(ref?.value, 'PositiveMongolians');
    });

    test('parses /user/ username URL', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://www.youtube.com/user/GoogleDevelopers',
      );
      expect(ref?.kind, YoutubeChannelRefKind.username);
      expect(ref?.value, 'GoogleDevelopers');
    });

    test('parses legacy vanity path youtube.com/orgiluuntv2', () {
      final ref = YoutubeIdParser.parseChannelRef('youtube.com/orgiluuntv2');
      expect(ref, isNotNull);
      expect(ref!.kind, YoutubeChannelRefKind.vanity);
      expect(ref.value, 'orgiluuntv2');
      expect(ref.displayLabel, '/orgiluuntv2');
      expect(ref.publicPath, '/orgiluuntv2');
      expect(ref.requiresApiLookup, isTrue);
    });

    test('parses vanity with https and si= junk', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'https://youtube.com/orgiluuntv2?si=ShareJunk123',
      );
      expect(ref?.kind, YoutubeChannelRefKind.vanity);
      expect(ref?.value, 'orgiluuntv2');
    });

    test('parses vanity from messy paste text', () {
      final ref = YoutubeIdParser.parseChannelRef(
        'Check this: youtube.com/orgiluuntv2?si=abc!',
      );
      expect(ref?.kind, YoutubeChannelRefKind.vanity);
      expect(ref?.value, 'orgiluuntv2');
    });

    test('parses relative /@handle path', () {
      final ref = YoutubeIdParser.parseChannelRef('/@Damisuna');
      expect(ref?.kind, YoutubeChannelRefKind.handle);
      expect(ref?.value, 'Damisuna');
    });

    test('rejects reserved paths as vanity', () {
      expect(YoutubeIdParser.parseChannelRef('youtube.com/watch'), isNull);
      expect(YoutubeIdParser.parseChannelRef('youtube.com/playlist'), isNull);
      expect(YoutubeIdParser.parseChannelRef('youtube.com/feed'), isNull);
      expect(YoutubeIdParser.parseChannelRef('youtube.com/results'), isNull);
    });

    test('rejects garbage', () {
      expect(YoutubeIdParser.parseChannelRef(''), isNull);
      expect(YoutubeIdParser.parseChannelRef('not a channel'), isNull);
      expect(YoutubeIdParser.parseChannelRef('https://example.com/foo'), isNull);
    });
  });
}
