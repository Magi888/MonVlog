import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/form_factor.dart';
import '../../app/theme.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_repository.dart';
import '../../data/models/shelf.dart';
import '../../data/models/video_item.dart';
import '../../data/shelf_categorizer.dart';
import '../../l10n/app_localizations.dart';
import '../home/widgets/poster_card.dart';

/// Netflix-style channel page: header + horizontal video / playlist shelves.
class ChannelBrowseScreen extends ConsumerWidget {
  const ChannelBrowseScreen({
    super.key,
    required this.channelId,
    this.fallbackName = '',
  });

  final String channelId;
  final String fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(channelCatalogProvider(channelId));
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: MonVlogTheme.bg,
      body: catalog.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: MonVlogTheme.brandRed),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.catalogError('$err'),
              style: GoogleFonts.manrope(color: MonVlogTheme.onBg),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (snapshot) => _ChannelBody(
          snapshot: snapshot,
          fallbackName: fallbackName,
          topInset: top,
          isTv: FormFactor.isTvLayout(context),
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(
                FormFactor.isTvLayout(context) ? '/tv' : '/phone',
              );
            }
          },
          onRetry: () => ref.invalidate(channelCatalogProvider(channelId)),
        ),
      ),
    );
  }
}

class _ChannelBody extends StatelessWidget {
  const _ChannelBody({
    required this.snapshot,
    required this.fallbackName,
    required this.topInset,
    required this.isTv,
    required this.onBack,
    required this.onRetry,
  });

  final ChannelCatalogSnapshot snapshot;
  final String fallbackName;
  final double topInset;
  final bool isTv;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final channel = snapshot.channel;
    final name = channel.displayName.isNotEmpty
        ? channel.displayName
        : (fallbackName.isNotEmpty ? fallbackName : l10n.channel);
    final source = snapshot.isMock ? l10n.mockCatalog : l10n.liveYoutube;
    final category = ShelfTypes.localizedTitle(channel.category, l10n);
    final hPad = isTv ? 36.0 : 16.0;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.goBack): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.browserBack): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              onBack();
              return null;
            },
          ),
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _ChannelHero(
                topInset: topInset,
                name: name,
                handle: channel.handle,
                category: category,
                source: source,
                thumbnailUrl: snapshot.thumbnailUrl,
                description: snapshot.description,
                isTv: isTv,
                onBack: onBack,
                onRetry: snapshot.isMock ? onRetry : null,
              ),
            ),
            if (snapshot.message.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                  child: Text(
                    snapshot.message,
                    style: GoogleFonts.manrope(
                      color: MonVlogTheme.muted,
                      fontSize: isTv ? 14 : 12,
                    ),
                  ),
                ),
              ),
            if (snapshot.shelves.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.channelEmpty,
                    style: GoogleFonts.manrope(color: MonVlogTheme.muted),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ChannelShelf(
                    shelf: snapshot.shelves[index],
                    isTv: isTv,
                    autofocusFirst: isTv && index == 0,
                  ),
                  childCount: snapshot.shelves.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ChannelHero extends StatelessWidget {
  const _ChannelHero({
    required this.topInset,
    required this.name,
    required this.handle,
    required this.category,
    required this.source,
    required this.thumbnailUrl,
    required this.description,
    required this.isTv,
    required this.onBack,
    this.onRetry,
  });

  final double topInset;
  final String name;
  final String handle;
  final String category;
  final String source;
  final String thumbnailUrl;
  final String description;
  final bool isTv;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hPad = isTv ? 36.0 : 16.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: (isTv ? 260 : 200) + topInset,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnailUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: MonVlogTheme.surface),
                  errorWidget: (_, __, ___) => Container(
                    color: MonVlogTheme.surface,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.live_tv_rounded,
                      color: MonVlogTheme.muted,
                      size: 48,
                    ),
                  ),
                )
              else
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MonVlogTheme.brandRedDeep,
                        MonVlogTheme.bg,
                      ],
                    ),
                  ),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0xEE0B0B0F),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: topInset + 4,
                left: isTv ? 24 : 4,
                child: IconButton(
                  autofocus: false,
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: hPad,
                right: hPad,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: isTv ? 36 : 26,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (handle.isNotEmpty)
                          Text(
                            handle.startsWith('@') ? handle : '@$handle',
                            style: GoogleFonts.manrope(
                              color: Colors.white70,
                              fontSize: isTv ? 16 : 13,
                            ),
                          ),
                        Text(
                          category,
                          style: GoogleFonts.manrope(
                            color: MonVlogTheme.coral,
                            fontSize: isTv ? 14 : 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: MonVlogTheme.brandRed.withValues(alpha: 0.2),
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
                        if (onRetry != null)
                          TextButton(
                            onPressed: onRetry,
                            child: Text(l10n.retry),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (description.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
            child: Text(
              description.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: MonVlogTheme.muted,
                fontSize: isTv ? 15 : 13,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChannelShelf extends StatelessWidget {
  const _ChannelShelf({
    required this.shelf,
    required this.isTv,
    this.autofocusFirst = false,
  });

  final Shelf shelf;
  final bool isTv;
  final bool autofocusFirst;

  @override
  Widget build(BuildContext context) {
    final hPad = isTv ? 36.0 : 16.0;
    // TV reuses focusable [PosterCard] (D-pad / Select). Phone keeps compact posters.
    if (isTv) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
              child: Text(
                shelf.title,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: shelf.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
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
              padding: EdgeInsets.symmetric(horizontal: hPad),
              itemCount: shelf.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _ChannelPoster(item: shelf.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelPoster extends StatelessWidget {
  const _ChannelPoster({required this.item});

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
