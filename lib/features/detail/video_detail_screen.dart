import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/video_item.dart';
import '../../platform/youtube_intent.dart';

/// TV detail: metadata + primary Play action (playback arrives in M3).
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
      if (mounted) _playFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _playFocus.dispose();
    super.dispose();
  }

  void _onPlay() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Play “${widget.item.title}” — in-app player arrives in M3',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openExternal() async {
    await YoutubeIntent.openWatchUrl(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final published = item.publishedAt;
    final metaBits = <String>[
      if (item.channelName.isNotEmpty) item.channelName,
      if (item.durationLabel.isNotEmpty) item.durationLabel,
      if (published != null)
        '${published.year}-${published.month.toString().padLeft(2, '0')}-${published.day.toString().padLeft(2, '0')}',
      if (item.viewCount != null) _formatViews(item.viewCount!),
    ];

    return Scaffold(
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
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
                return null;
              },
            ),
          },
          child: Padding(
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
                      child: item.thumbnailUrl.isEmpty
                          ? Container(
                              color: MonVlogTheme.surface,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.movie_outlined,
                                size: 64,
                                color: MonVlogTheme.muted,
                              ),
                            )
                          : CachedNetworkImage(
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
                            ),
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
                                : 'No description available for this video.',
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
                            label: 'Play',
                            primary: true,
                            onPressed: _onPlay,
                          ),
                          _TvButton(
                            label: 'Open in YouTube',
                            onPressed: _openExternal,
                          ),
                          _TvButton(
                            label: 'Back',
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                          ),
                        ],
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
        ? (_focused ? MonVlogTheme.accent : MonVlogTheme.accent.withValues(alpha: 0.85))
        : (_focused ? MonVlogTheme.surface : MonVlogTheme.surface.withValues(alpha: 0.7));
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.primary ? MonVlogTheme.onBg : MonVlogTheme.onBg,
            ),
          ),
        ),
      ),
    );
  }
}
