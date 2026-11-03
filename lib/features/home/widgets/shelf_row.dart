import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/shelf.dart';
import 'poster_card.dart';

class ShelfRow extends StatelessWidget {
  const ShelfRow({
    super.key,
    required this.shelf,
    this.autofocusFirst = false,
  });

  final Shelf shelf;
  final bool autofocusFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 12),
            child: Text(
              shelf.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: MonVlogTheme.onBg,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              itemCount: shelf.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return PosterCard(
                  item: shelf.items[index],
                  autofocus: autofocusFirst && index == 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
