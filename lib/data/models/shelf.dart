import 'video_item.dart';

class Shelf {
  const Shelf({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<VideoItem> items;
}
