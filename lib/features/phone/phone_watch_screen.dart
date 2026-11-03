import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_repository.dart';
import '../../data/models/shelf.dart';
import '../../data/models/video_item.dart';

/// Phone video shelves — reuses mock/live catalog; look-first layout.
class PhoneWatchScreen extends ConsumerWidget {
  const PhoneWatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(homeCatalogProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: MonVlogTheme.cardWhite,
      body: catalog.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: MonVlogTheme.brandRed),
        ),
        error: (err, _) => Center(
          child: Text(
            'Catalog error: $err',
            style: const TextStyle(color: MonVlogTheme.navy),
          ),
        ),
        data: (snapshot) => _WatchBody(
          snapshot: snapshot,
          topInset: top,
          onRetry: () => ref.invalidate(homeCatalogProvider),
        ),
      ),
    );
  }
}

class _WatchBody extends StatelessWidget {
  const _WatchBody({
    required this.snapshot,
    required this.topInset,
    required this.onRetry,
  });

  final CatalogSnapshot snapshot;
  final double topInset;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final source = snapshot.isMock ? 'Mock catalog' : 'Live YouTube';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 40,
                    color: MonVlogTheme.navy,
                    letterSpacing: 1.4,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: MonVlogTheme.brandRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        source,
                        style: GoogleFonts.manrope(
                          color: MonVlogTheme.brandRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'No API key required',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: MonVlogTheme.memberGrey,
                      ),
                    ),
                    if (snapshot.isMock) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _PhoneShelf(shelf: snapshot.shelves[index]),
            childCount: snapshot.shelves.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _PhoneShelf extends StatelessWidget {
  const _PhoneShelf({required this.shelf});

  final Shelf shelf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Text(
              shelf.title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: MonVlogTheme.navy,
              ),
            ),
          ),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: shelf.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _PhonePoster(item: shelf.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePoster extends StatelessWidget {
  const _PhonePoster({required this.item});

  final VideoItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/detail', extra: item),
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: MonVlogTheme.softGrey,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.movie_outlined,
                          color: MonVlogTheme.memberGrey,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: MonVlogTheme.softGrey,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: MonVlogTheme.memberGrey,
                        ),
                      ),
                    ),
                    if (item.durationLabel.isNotEmpty)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.durationLabel,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MonVlogTheme.navy,
              ),
            ),
            Text(
              item.channelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: MonVlogTheme.memberGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
