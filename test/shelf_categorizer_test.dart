import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/models/video_item.dart';
import 'package:monvlog/data/shelf_categorizer.dart';

void main() {
  const categorizer = ShelfCategorizer();

  group('ShelfCategorizer.categorizeText', () {
    test('detects travel from title/description', () {
      expect(
        categorizer.categorizeText(
          title: 'Europe Tour Day 3',
          description: 'Road trip across Mongolia',
        ),
        ShelfTypes.travel,
      );
      expect(
        categorizer.categorizeText(title: 'Аялал Улаанбаатар'),
        ShelfTypes.travel,
      );
    });

    test('detects food keywords', () {
      expect(
        categorizer.categorizeText(
          title: 'Cooking бууз',
          description: 'Restaurant mukbang',
        ),
        ShelfTypes.food,
      );
      expect(
        categorizer.categorizeText(title: 'Хоол хийх tip'),
        ShelfTypes.food,
      );
    });

    test('detects featured / special', () {
      expect(
        categorizer.categorizeText(title: 'Premiere trailer announcement'),
        ShelfTypes.featured,
      );
    });

    test('falls back to daily when no strong signal', () {
      expect(
        categorizer.categorizeText(title: 'Hello friends'),
        ShelfTypes.daily,
      );
      expect(
        categorizer.categorizeText(title: ''),
        ShelfTypes.daily,
      );
    });

    test('daily vlog keywords', () {
      expect(
        categorizer.categorizeText(title: 'Morning routine vlog'),
        ShelfTypes.daily,
      );
    });
  });

  group('ShelfCategorizer.categorizeVideo', () {
    test('uses video title and description', () {
      const video = VideoItem(
        id: '1',
        title: 'Food tour in UB',
        channelName: 'Chef',
        thumbnailUrl: '',
        description: 'Best restaurants and cooking tips',
      );
      expect(categorizer.categorizeVideo(video), ShelfTypes.food);
    });

    test('respects explicit fallback when empty', () {
      const video = VideoItem(
        id: '2',
        title: '',
        channelName: 'x',
        thumbnailUrl: '',
      );
      expect(
        categorizer.categorizeVideo(video, fallback: ShelfTypes.travel),
        ShelfTypes.travel,
      );
    });
  });

  test('ShelfTypes.displayTitle', () {
    expect(ShelfTypes.displayTitle(ShelfTypes.travel), 'Travel');
    expect(ShelfTypes.displayTitle(ShelfTypes.food), 'Food');
    expect(ShelfTypes.displayTitle('unknown'), 'unknown');
  });
}
