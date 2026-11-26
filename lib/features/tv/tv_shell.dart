import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../locale/language_switch.dart';
import '../home/widgets/shelf_row.dart';

/// Netflix-style Android TV / Google TV (Samsung living-room) shell.
/// Left rail navigation — no phone bottom bar.
class TvShell extends ConsumerStatefulWidget {
  const TvShell({super.key, this.initialSection = 0});

  final int initialSection;

  @override
  ConsumerState<TvShell> createState() => _TvShellState();
}

class _TvShellState extends ConsumerState<TvShell> {
  late int _section;
  final _contentFocus = FocusNode(debugLabel: 'tv-content');

  List<(IconData, String)> _nav(AppLocalizations l10n) => [
    (Icons.home_rounded, l10n.tvNavHome),
    (Icons.people_outline_rounded, l10n.tvNavCreators),
    (Icons.search_rounded, l10n.tvNavSearch),
    (Icons.video_library_outlined, l10n.tvNavLibrary),
    (Icons.settings_outlined, l10n.tvNavSettings),
  ];

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection.clamp(0, 4);
  }

  @override
  void dispose() {
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nav = _nav(l10n);
    return Scaffold(
      backgroundColor: MonVlogTheme.bg,
      body: Row(
        children: [
          _TvLeftRail(
            selected: _section,
            items: nav,
            onSelect: (i) => setState(() => _section = i),
            onMoveRight: () => _contentFocus.requestFocus(),
          ),
          Expanded(
            child: Focus(
              focusNode: _contentFocus,
              child: _TvSectionBody(section: _section),
            ),
          ),
        ],
      ),
    );
  }
}

class _TvLeftRail extends StatelessWidget {
  const _TvLeftRail({
    required this.selected,
    required this.items,
    required this.onSelect,
    required this.onMoveRight,
  });

  final int selected;
  final List<(IconData, String)> items;
  final ValueChanged<int> onSelect;
  final VoidCallback onMoveRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      color: MonVlogTheme.rail,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Text(
              'MV',
              style: GoogleFonts.bebasNeue(
                color: MonVlogTheme.brandRed,
                fontSize: 28,
                letterSpacing: 1,
              ),
            ),
          ),
          for (var i = 0; i < items.length; i++)
            _RailItem(
              icon: items[i].$1,
              label: items[i].$2,
              selected: selected == i,
              autofocus: i == 0,
              onSelect: () => onSelect(i),
              onMoveRight: onMoveRight,
            ),
          const Spacer(),
          Text(
            'TV',
            style: GoogleFonts.manrope(
              color: MonVlogTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onSelect,
    required this.onMoveRight,
    this.autofocus = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onMoveRight;
  final bool autofocus;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _focused;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        onShowFocusHighlight: (f) => setState(() => _focused = f),
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.arrowRight):
              const _MoveRightIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onSelect();
              return null;
            },
          ),
          _MoveRightIntent: CallbackAction<_MoveRightIntent>(
            onInvoke: (_) {
              widget.onMoveRight();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: widget.onSelect,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? MonVlogTheme.brandRed.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focused ? MonVlogTheme.focusRing : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  widget.icon,
                  color: active ? Colors.white : MonVlogTheme.muted,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : MonVlogTheme.muted,
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

class _MoveRightIntent extends Intent {
  const _MoveRightIntent();
}

class _TvSectionBody extends ConsumerWidget {
  const _TvSectionBody({required this.section});

  final int section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (section) {
      case 0:
        return const _TvHomeRails();
      case 1:
        return _TvPlaceholder(
          title: AppLocalizations.of(context).tvNavCreators,
          subtitle: AppLocalizations.of(context).tvCreatorsSubtitle,
        );
      case 2:
        return _TvPlaceholder(
          title: AppLocalizations.of(context).tvNavSearch,
          subtitle: AppLocalizations.of(context).tvSearchSubtitle,
        );
      case 3:
        return _TvPlaceholder(
          title: AppLocalizations.of(context).tvNavLibrary,
          subtitle: AppLocalizations.of(context).tvLibrarySubtitle,
        );
      default:
        return const _TvSettingsSection();
    }
  }
}

class _TvSettingsSection extends ConsumerWidget {
  const _TvSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 40, 36, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tvNavSettings,
            style: GoogleFonts.bebasNeue(
              color: MonVlogTheme.onBg,
              fontSize: 42,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.tvSettingsBlurb,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.muted,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.language,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.onBg,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          const LanguageSwitchTile(),
          const SizedBox(height: 20),
          if (isAdmin)
            FilledButton.icon(
              onPressed: () => context.go('/admin/catalog'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text(
                l10n.openCatalogAdmin,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: MonVlogTheme.brandRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () => context.go('/admin/login'),
              icon: const Icon(Icons.lock_outline_rounded),
              label: Text(
                l10n.adminSignIn,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            isAdmin
                ? l10n.catalogAdminSignedIn
                : l10n.watchOnlyAccess,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TvHomeRails extends ConsumerStatefulWidget {
  const _TvHomeRails();

  @override
  ConsumerState<_TvHomeRails> createState() => _TvHomeRailsState();
}

class _TvHomeRailsState extends ConsumerState<_TvHomeRails> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(homeCatalogProvider);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown):
            ScrollIntent(direction: AxisDirection.down),
        SingleActivator(LogicalKeyboardKey.arrowUp):
            ScrollIntent(direction: AxisDirection.up),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ScrollIntent: CallbackAction<ScrollIntent>(
            onInvoke: (intent) {
              if (!_scrollController.hasClients) return null;
              final delta =
                  intent.direction == AxisDirection.down ? 240.0 : -240.0;
              _scrollController.animateTo(
                (_scrollController.offset + delta).clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
              return null;
            },
          ),
        },
        child: catalog.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: MonVlogTheme.accent),
          ),
          error: (err, _) => Center(
            child: Text(
              'Catalog error: $err',
              style: const TextStyle(color: MonVlogTheme.onBg),
            ),
          ),
          data: (snapshot) => _TvRailsBody(
            snapshot: snapshot,
            scrollController: _scrollController,
            onRetry: () => ref.invalidate(homeCatalogProvider),
          ),
        ),
      ),
    );
  }
}

class _TvRailsBody extends StatelessWidget {
  const _TvRailsBody({
    required this.snapshot,
    required this.scrollController,
    required this.onRetry,
  });

  final CatalogSnapshot snapshot;
  final ScrollController scrollController;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = snapshot.isMock ? 'Mock catalog' : 'Live YouTube';

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 36, 48, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MonVlog',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 48,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mongolian vlogs for the living room',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: MonVlogTheme.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MonVlogTheme.brandRed.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sourceLabel,
                        style: GoogleFonts.manrope(
                          color: MonVlogTheme.coral,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'D-pad · focus shelves · Samsung via Android TV / Google TV',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: MonVlogTheme.muted,
                      ),
                    ),
                    if (snapshot.isMock)
                      TextButton(onPressed: onRetry, child: const Text('Retry')),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Featured billboard strip
        if (snapshot.shelves.isNotEmpty)
          SliverToBoxAdapter(
            child: _FeaturedBillboard(
              title: snapshot.shelves.first.items.isNotEmpty
                  ? snapshot.shelves.first.items.first.title
                  : 'Featured',
              channel: snapshot.shelves.first.items.isNotEmpty
                  ? snapshot.shelves.first.items.first.channelName
                  : '',
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final shelf = snapshot.shelves[index];
              return ShelfRow(
                shelf: shelf,
                autofocusFirst: index == 0,
              );
            },
            childCount: snapshot.shelves.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

class _FeaturedBillboard extends StatelessWidget {
  const _FeaturedBillboard({
    required this.title,
    required this.channel,
  });

  final String title;
  final String channel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 12, 48, 28),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3A1010),
              Color(0xFF1A0A12),
              MonVlogTheme.bg,
            ],
          ),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'FEATURED',
              style: GoogleFonts.manrope(
                color: MonVlogTheme.brandRed,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.bebasNeue(
                fontSize: 40,
                color: Colors.white,
                letterSpacing: 1,
                height: 1.05,
              ),
            ),
            if (channel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                channel,
                style: GoogleFonts.manrope(
                  color: MonVlogTheme.muted,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TvPlaceholder extends StatelessWidget {
  const _TvPlaceholder({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.bebasNeue(
              fontSize: 48,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: MonVlogTheme.muted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
