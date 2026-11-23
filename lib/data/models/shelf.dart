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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Shelf.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <VideoItem>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          items.add(VideoItem.fromJson(item));
        } else if (item is Map) {
          items.add(VideoItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return Shelf(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: items,
    );
  }
}
