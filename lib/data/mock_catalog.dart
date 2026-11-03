import 'models/shelf.dart';
import 'models/video_item.dart';

/// Mock Mongolian-vlog catalog for M0. No YouTube API keys.
class MockCatalog {
  static const List<Shelf> shelves = [
    Shelf(
      id: 'featured',
      title: 'Featured',
      items: [
        VideoItem(
          id: 'mock_1',
          title: 'Ulaanbaatar morning walk',
          channelName: 'Ger Life Vlogs',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog1/480/270',
          durationLabel: '12:04',
        ),
        VideoItem(
          id: 'mock_2',
          title: 'Gobi road trip — day 1',
          channelName: 'Steppe Travels',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog2/480/270',
          durationLabel: '18:32',
        ),
        VideoItem(
          id: 'mock_3',
          title: 'Buuz weekend at home',
          channelName: 'Daily Nomad',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog3/480/270',
          durationLabel: '9:15',
        ),
        VideoItem(
          id: 'mock_4',
          title: 'Naadam highlights 2025',
          channelName: 'Mongol Moments',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog4/480/270',
          durationLabel: '22:41',
        ),
      ],
    ),
    Shelf(
      id: 'new',
      title: 'New from creators',
      items: [
        VideoItem(
          id: 'mock_5',
          title: 'Apartment tour in Darkhan',
          channelName: 'City Side',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog5/480/270',
          durationLabel: '14:08',
        ),
        VideoItem(
          id: 'mock_6',
          title: 'Horse trek with dad',
          channelName: 'Ger Life Vlogs',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog6/480/270',
          durationLabel: '27:03',
        ),
        VideoItem(
          id: 'mock_7',
          title: 'Night market food crawl',
          channelName: 'Taste of MN',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog7/480/270',
          durationLabel: '11:55',
        ),
      ],
    ),
    Shelf(
      id: 'travel',
      title: 'Travel',
      items: [
        VideoItem(
          id: 'mock_8',
          title: 'Khuvsgul lake camping',
          channelName: 'Steppe Travels',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog8/480/270',
          durationLabel: '16:20',
        ),
        VideoItem(
          id: 'mock_9',
          title: 'Trans-Mongolian train diary',
          channelName: 'Mongol Moments',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog9/480/270',
          durationLabel: '31:12',
        ),
        VideoItem(
          id: 'mock_10',
          title: 'Orkhon valley hike',
          channelName: 'Daily Nomad',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog10/480/270',
          durationLabel: '19:44',
        ),
      ],
    ),
    Shelf(
      id: 'continue',
      title: 'Continue watching',
      items: [
        VideoItem(
          id: 'mock_11',
          title: 'Winter ger setup (part 2)',
          channelName: 'Ger Life Vlogs',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog11/480/270',
          durationLabel: '8:02',
        ),
        VideoItem(
          id: 'mock_12',
          title: 'Market day leftovers',
          channelName: 'Taste of MN',
          thumbnailUrl: 'https://picsum.photos/seed/monvlog12/480/270',
          durationLabel: '6:40',
        ),
      ],
    ),
  ];
}
