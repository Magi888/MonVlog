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

/// Phone Netflix-style Watch — dark horizontal content rails.
class PhoneWatchScreen extends ConsumerWidget {
  const PhoneWatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(homeCatalogProvider);
    final top = MediaQuery.paddingOf(context).top;

    // Body-only — [PhoneShell] owns the Scaffold + bottom menu.
    return ColoredBox(
      color: MonVlogTheme.bg,
      child: catalog.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: MonVlogTheme.brandRed),
        ),
        error: (err, _) => Center(
          child: Text(
            'Catalog error: $err',
            style: const TextStyle(color: MonVlogTheme.onBg),
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
    final featured = snapshot.shelves.isNotEmpty &&
            snapshot.shelves.first.items.isNotEmpty
        ? snapshot.shelves.first.items.first
        : null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                Text(
                  'MonVlog',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 28,
                    color: MonVlogTheme.brandRed,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: MonVlogTheme.brandRed.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    source,
                    style: GoogleFonts.manrope(
                      color: MonVlogTheme.coral,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (snapshot.isMock)
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        if (featured != null)
          SliverToBoxAdapter(
            child: _HeroPoster(
              item: featured,
              onTap: () => context.push('/detail', extra: featured),
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

class _HeroPoster extends StatelessWidget {
  const _HeroPoster({required this.item, required this.onTap});

  final VideoItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: item.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: MonVlogTheme.surface),
                  errorWidget: (_, __, ___) =>
                      Container(color: MonVlogTheme.surface),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC0B0B0F),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        item.channelName,
                        style: GoogleFonts.manrope(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Text(
              shelf.title,
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: shelf.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
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
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: MonVlogTheme.surface),
                      errorWidget: (_, __, ___) => Container(
                        color: MonVlogTheme.surface,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: MonVlogTheme.muted,
                        ),
                      ),
                    ),
                    if (item.durationLabel.isNotEmpty)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(3),
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
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              item.channelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: MonVlogTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
