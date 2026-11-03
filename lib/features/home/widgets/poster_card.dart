import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/models/video_item.dart';
import '../../../platform/youtube_intent.dart';

class PosterCard extends StatefulWidget {
  const PosterCard({
    super.key,
    required this.item,
    this.autofocus = false,
  });

  final VideoItem item;
  final bool autofocus;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _focused = false;

  void _onActivate() {
    context.push('/detail', extra: widget.item);
  }

  Future<void> _onLongSelect() async {
    await YoutubeIntent.openWatchUrl(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _focused ? 1.06 : 1.0;
    final border = _focused
        ? Border.all(color: MonVlogTheme.accent, width: 3)
        : Border.all(color: Colors.transparent, width: 3);

    return FocusableActionDetector(
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
            _onActivate();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: _onActivate,
        onLongPress: _onLongSelect,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 320,
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(8),
              color: MonVlogTheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.item.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: MonVlogTheme.surface,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.movie_outlined,
                            color: MonVlogTheme.muted,
                            size: 40,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: MonVlogTheme.surface,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: MonVlogTheme.muted,
                          ),
                        ),
                      ),
                      if (widget.item.durationLabel.isNotEmpty)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            color: Colors.black87,
                            child: Text(
                              widget.item.durationLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MonVlogTheme.onBg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.channelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MonVlogTheme.muted,
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
