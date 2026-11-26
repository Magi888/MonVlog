import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../app/form_factor.dart';
import '../../app/theme.dart';
import '../../data/models/video_item.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/youtube_intent.dart';

String _browseHome(BuildContext context) =>
    FormFactor.isTvLayout(context) ? '/tv' : '/phone';

/// In-app YouTube playback (IFrame API via [youtube_player_flutter]).
///
/// Phone-first; same route works on Android TV / leanback viewports.
class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({super.key, required this.item});

  final VideoItem item;

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  YoutubePlayerController? _controller;
  final _playFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final id = widget.item.id.trim();
    if (id.isNotEmpty) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          playsInline: true,
          strictRelatedVideos: true,
          // Explicit client identity avoids YouTube embed error 153 on release.
          appId: 'com.monvlog.monvlog',
          interfaceLanguage: 'mn',
          captionLanguage: 'mn',
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && FormFactor.isTvLayout(context)) {
        _playFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _playFocus.dispose();
    _controller?.close();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_browseHome(context));
    }
  }

  Future<void> _openExternal() async {
    final id = widget.item.id.trim();
    if (id.isEmpty) return;
    await YoutubeIntent.openWatchUrl(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;
    final isTv = FormFactor.isTvLayout(context);
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
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
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(isTv ? 32 : 8, 4, isTv ? 32 : 8, 4),
                  child: Row(
                    children: [
                      IconButton(
                        focusNode: isTv ? _playFocus : null,
                        autofocus: isTv,
                        tooltip: l10n.back,
                        onPressed: _goBack,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isTv ? 22 : 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: item.id.trim().isEmpty ? null : _openExternal,
                        child: Text(
                          l10n.openInYoutube,
                          style: GoogleFonts.manrope(
                            color: MonVlogTheme.coral,
                            fontWeight: FontWeight.w700,
                            fontSize: isTv ? 16 : 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: controller == null
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.playerMissingId,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: MonVlogTheme.muted,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : YoutubePlayer(
                            controller: controller,
                            aspectRatio: 16 / 9,
                            backgroundColor: Colors.black,
                            // Dedicated player route — start immediately.
                            autoPlayWhenVisible: false,
                          ),
                  ),
                ),
                if (item.channelName.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTv ? 48 : 16,
                      8,
                      isTv ? 48 : 16,
                      isTv ? 28 : 16,
                    ),
                    child: Text(
                      item.channelName,
                      style: GoogleFonts.manrope(
                        color: MonVlogTheme.muted,
                        fontSize: isTv ? 18 : 13,
                      ),
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
