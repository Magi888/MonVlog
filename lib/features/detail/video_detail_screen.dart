import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/form_factor.dart';
import '../../app/theme.dart';
import '../../data/models/video_item.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/youtube_intent.dart';

String _browseHome(BuildContext context) =>
    FormFactor.isTvLayout(context) ? '/tv' : '/phone';

/// Video metadata + Play (in-app player) / Open in YouTube.
///
/// Phone uses a vertical scroll layout; TV keeps the leanback side-by-side UI.
class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key, required this.item});

  final VideoItem item;

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final _playFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && FormFactor.isTvLayout(context)) {
        _playFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _playFocus.dispose();
    super.dispose();
  }

  void _onPlay() {
    final id = widget.item.id.trim();
    if (id.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.playerMissingId),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    context.push('/play', extra: widget.item);
  }

  Future<void> _openExternal() async {
    await YoutubeIntent.openWatchUrl(widget.item.id);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_browseHome(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTv = FormFactor.isTvLayout(context);
    return Scaffold(
      backgroundColor: MonVlogTheme.bg,
      body: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.goBack): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.browserBack): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                _goBack();
                return null;
              },
            ),
          },
          child: isTv ? _buildTv(context) : _buildPhone(context),
        ),
      ),
    );
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;
    final top = MediaQuery.paddingOf(context).top;
    final metaBits = _metaBits(item);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, top + 4, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back, color: MonVlogTheme.onBg),
                ),
                Expanded(
                  child: Text(
                    l10n.play,
                    style: GoogleFonts.manrope(
                      color: MonVlogTheme.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _Thumbnail(item: item),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MonVlogTheme.onBg,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  metaBits.join(' · '),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: MonVlogTheme.muted,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _onPlay,
                    style: FilledButton.styleFrom(
                      backgroundColor: MonVlogTheme.brandRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      l10n.play,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openExternal,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MonVlogTheme.onBg,
                      side: const BorderSide(color: MonVlogTheme.muted),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      l10n.openInYoutube,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : l10n.noDescription,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.45,
                    color: MonVlogTheme.onBg,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTv(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;
    final metaBits = _metaBits(item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 40, 48, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _Thumbnail(item: item),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: MonVlogTheme.onBg,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  metaBits.join(' · '),
                  style: const TextStyle(
                    fontSize: 18,
                    color: MonVlogTheme.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      item.description.isNotEmpty
                          ? item.description
                          : l10n.noDescription,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.45,
                        color: MonVlogTheme.onBg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _TvButton(
                      focusNode: _playFocus,
                      autofocus: true,
                      label: l10n.play,
                      primary: true,
                      onPressed: _onPlay,
                    ),
                    _TvButton(
                      label: l10n.openInYoutube,
                      onPressed: _openExternal,
                    ),
                    _TvButton(
                      label: l10n.back,
                      onPressed: _goBack,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _metaBits(VideoItem item) {
    final published = item.publishedAt;
    return <String>[
      if (item.channelName.isNotEmpty) item.channelName,
      if (item.durationLabel.isNotEmpty) item.durationLabel,
      if (published != null)
        '${published.year}-${published.month.toString().padLeft(2, '0')}-${published.day.toString().padLeft(2, '0')}',
      if (item.viewCount != null) _formatViews(item.viewCount!),
    ];
  }

  static String _formatViews(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    }
    return '$count views';
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});

  final VideoItem item;

  @override
  Widget build(BuildContext context) {
    if (item.thumbnailUrl.isEmpty) {
      return Container(
        color: MonVlogTheme.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.movie_outlined,
          size: 64,
          color: MonVlogTheme.muted,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: item.thumbnailUrl,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Container(
        color: MonVlogTheme.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: MonVlogTheme.muted,
        ),
      ),
    );
  }
}

class _TvButton extends StatefulWidget {
  const _TvButton({
    required this.label,
    required this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool primary;

  @override
  State<_TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<_TvButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? (_focused
            ? MonVlogTheme.accent
            : MonVlogTheme.accent.withValues(alpha: 0.85))
        : (_focused
            ? MonVlogTheme.surface
            : MonVlogTheme.surface.withValues(alpha: 0.7));
    final border = _focused
        ? Border.all(color: MonVlogTheme.onBg, width: 2)
        : Border.all(color: Colors.transparent, width: 2);

    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: (focused) => setState(() => _focused = focused),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: border,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MonVlogTheme.onBg,
            ),
          ),
        ),
      ),
    );
  }
}
