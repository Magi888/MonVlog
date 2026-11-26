import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../data/catalog_providers.dart';
import '../../data/shelf_categorizer.dart';
import '../../data/youtube/youtube_search_models.dart';
import '../../l10n/app_localizations.dart';

/// Admin-only: search YouTube channels/playlists and add to curated catalog.
class AdminCatalogScreen extends ConsumerStatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  ConsumerState<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends ConsumerState<AdminCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    ref.read(channelSearchQueryProvider.notifier).state =
        _searchCtrl.text.trim();
  }

  Future<void> _addHit(YoutubeSearchHit hit) async {
    final l10n = AppLocalizations.of(context);
    final store = ref.read(catalogStoreProvider);
    if (hit.isPlaylist) {
      await store.addPlaylist(
        playlistId: hit.id,
        title: hit.title,
        channelId: hit.channelId,
        channelName: hit.channelTitle,
      );
      setState(() => _status = l10n.addedPlaylist(hit.title));
    } else {
      final channel = await store.addChannel(
        channelId: hit.id,
        displayName: hit.title,
        handle: hit.channelTitle.isNotEmpty ? '@${hit.channelTitle}' : '',
        descriptionForHeuristic: hit.description,
      );
      setState(
        () => _status = l10n.addedChannel(
          channel.displayName,
          ShelfTypes.localizedTitle(channel.category, l10n),
        ),
      );
    }
    ref.invalidate(curatedCatalogProvider);
    ref.invalidate(localPlaylistsProvider);
    ref.invalidate(homeCatalogProvider);
  }

  Future<void> _logout() async {
    await ref.read(adminSessionProvider.notifier).logout();
    if (mounted) context.go('/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/admin/login');
      });
      return const Scaffold(
        backgroundColor: MonVlogTheme.communityBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context);
    final search = ref.watch(channelSearchProvider);
    final catalog = ref.watch(curatedCatalogProvider);
    final playlists = ref.watch(localPlaylistsProvider);

    return Scaffold(
      backgroundColor: MonVlogTheme.communityBg,
      appBar: AppBar(
        backgroundColor: MonVlogTheme.communitySurface,
        title: Text(
          l10n.catalogAdmin,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/phone'),
            child: Text(
              l10n.browseApp,
              style: GoogleFonts.manrope(color: MonVlogTheme.coral),
            ),
          ),
          IconButton(
            tooltip: l10n.signOut,
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.searchYoutubeChannels,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MonVlogTheme.onBg,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.catalogAdminBlurb,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.manrope(color: MonVlogTheme.onBg),
                  decoration: InputDecoration(
                    hintText: l10n.channelNameHint,
                    hintStyle: GoogleFonts.manrope(color: MonVlogTheme.muted),
                    filled: true,
                    fillColor: MonVlogTheme.communitySurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onSubmitted: (_) => _runSearch(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _runSearch,
                style: FilledButton.styleFrom(
                  backgroundColor: MonVlogTheme.brandRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  l10n.search,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(
              _status!,
              style: GoogleFonts.manrope(
                color: MonVlogTheme.coral,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 20),
          search.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              l10n.searchError('$e'),
              style: GoogleFonts.manrope(color: MonVlogTheme.coral),
            ),
            data: (result) {
              if (ref.watch(channelSearchQueryProvider).trim().isEmpty) {
                return Text(
                  l10n.enterChannelToSearch,
                  style: GoogleFonts.manrope(color: MonVlogTheme.muted),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (result.isMock || result.message.isNotEmpty)
                    _MockBanner(message: result.message),
                  if (result.hits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l10n.noResults,
                        style: GoogleFonts.manrope(color: MonVlogTheme.muted),
                      ),
                    ),
                  for (final hit in result.hits)
                    _SearchHitTile(
                      hit: hit,
                      onAdd: () => _addHit(hit),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            l10n.curatedCatalog,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MonVlogTheme.onBg,
            ),
          ),
          const SizedBox(height: 8),
          catalog.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (config) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.channelsSource(config.channels.length, config.source),
                  style: GoogleFonts.manrope(
                    color: MonVlogTheme.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                for (final c in config.channels.take(40))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      c.displayName,
                      style: GoogleFonts.manrope(
                        color: MonVlogTheme.onBg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${c.channelId} · ${ShelfTypes.localizedTitle(c.category, l10n)}'
                      '${c.verified ? '' : ' · ${l10n.unverified}'}',
                      style: GoogleFonts.manrope(
                        color: MonVlogTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          playlists.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.localPlaylists(list.length),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: MonVlogTheme.onBg,
                    ),
                  ),
                  for (final p in list)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        p.title,
                        style: GoogleFonts.manrope(color: MonVlogTheme.onBg),
                      ),
                      subtitle: Text(
                        '${p.playlistId} · ${ShelfTypes.localizedTitle(p.category, l10n)}',
                        style: GoogleFonts.manrope(
                          color: MonVlogTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MockBanner extends StatelessWidget {
  const _MockBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MonVlogTheme.brandRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MonVlogTheme.brandRed.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: MonVlogTheme.coral, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.isEmpty
                  ? AppLocalizations.of(context).mockSearchBanner
                  : message,
              style: GoogleFonts.manrope(
                color: MonVlogTheme.onBg,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHitTile extends StatelessWidget {
  const _SearchHitTile({required this.hit, required this.onAdd});

  final YoutubeSearchHit hit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: MonVlogTheme.communitySurface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: MonVlogTheme.communityElevated,
          backgroundImage:
              hit.thumbnailUrl.isNotEmpty ? NetworkImage(hit.thumbnailUrl) : null,
          child: hit.thumbnailUrl.isEmpty
              ? Icon(
                  hit.isPlaylist
                      ? Icons.playlist_play_rounded
                      : Icons.person_rounded,
                  color: MonVlogTheme.muted,
                )
              : null,
        ),
        title: Text(
          hit.title,
          style: GoogleFonts.manrope(
            color: MonVlogTheme.onBg,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${hit.isPlaylist ? l10n.playlist : l10n.channel}'
          '${hit.isMock ? ' · ${l10n.mockLabel}' : ''}\n${hit.description}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(color: MonVlogTheme.muted, fontSize: 12),
        ),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: MonVlogTheme.brandRed,
          ),
          child: Text(
            l10n.add,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
