import '../l10n/app_localizations.dart';
import 'models/video_item.dart';

/// Shelf type ids used by home rails (matches curated channel categories).
abstract final class ShelfTypes {
  static const featured = 'featured';
  static const travel = 'travel';
  static const food = 'food';
  static const daily = 'daily';

  static const all = [featured, travel, food, daily];

  /// English fallback when no [AppLocalizations] is available (tests/data).
  static String displayTitle(String id) {
    switch (id) {
      case featured:
        return 'Featured';
      case travel:
        return 'Travel';
      case food:
        return 'Food';
      case daily:
        return 'Daily life';
      default:
        return id;
    }
  }

  static String localizedTitle(String id, AppLocalizations l10n) {
    switch (id) {
      case featured:
        return l10n.shelfFeatured;
      case travel:
        return l10n.shelfTravel;
      case food:
        return l10n.shelfFood;
      case daily:
        return l10n.shelfDaily;
      default:
        return id;
    }
  }
}

/// Simple keyword heuristics for auto-categorizing videos / channels into
/// shelf types. Editable later via admin CMS.
class ShelfCategorizer {
  const ShelfCategorizer();

  static const _travelKeywords = [
    'travel',
    'trip',
    'tour',
    'journey',
    'road',
    'europe',
    'mongolia',
    'mongolia tour',
    'аялал',
    'аялж',
    'travelling',
    'traveling',
    'adventure',
    'camping',
    'hike',
    'hiking',
  ];

  static const _foodKeywords = [
    'food',
    'cook',
    'cooking',
    'recipe',
    'restaurant',
    'kitchen',
    'хоол',
    'амттан',
    'eat',
    'eating',
    'mukbang',
    'cuisine',
    'bbq',
    'grill',
  ];

  static const _featuredKeywords = [
    'featured',
    'premiere',
    'special',
    'trailer',
    'announcement',
    'онцлох',
  ];

  static const _dailyKeywords = [
    'vlog',
    'daily',
    'day in',
    'life',
    'өдөр',
    'влог',
    'routine',
    'morning',
    'weekend',
  ];

  /// Categorize from free-text (title + description + optional tags).
  String categorizeText({
    String title = '',
    String description = '',
    List<String> keywords = const [],
    String fallback = ShelfTypes.daily,
  }) {
    final blob = [
      title,
      description,
      ...keywords,
    ].join(' ').toLowerCase();

    if (blob.trim().isEmpty) return fallback;

    final scores = <String, int>{
      ShelfTypes.featured: _score(blob, _featuredKeywords),
      ShelfTypes.travel: _score(blob, _travelKeywords),
      ShelfTypes.food: _score(blob, _foodKeywords),
      ShelfTypes.daily: _score(blob, _dailyKeywords),
    };

    var best = fallback;
    var bestScore = 0;
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        best = entry.key;
      }
    }
    return bestScore > 0 ? best : fallback;
  }

  /// Categorize a [VideoItem] for shelf placement.
  String categorizeVideo(VideoItem video, {String fallback = ShelfTypes.daily}) {
    return categorizeText(
      title: video.title,
      description: video.description,
      fallback: fallback,
    );
  }

  int _score(String blob, List<String> keywords) {
    var score = 0;
    for (final kw in keywords) {
      if (blob.contains(kw.toLowerCase())) {
        // Longer phrases weigh slightly more.
        score += kw.contains(' ') ? 3 : 2;
      }
    }
    return score;
  }
}
