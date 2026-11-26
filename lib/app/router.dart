import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'form_factor.dart';
import '../auth/admin_auth_providers.dart';
import '../data/models/video_item.dart';
import '../features/admin/admin_catalog_screen.dart';
import '../features/admin/admin_login_screen.dart';
import '../features/channel/channel_browse_screen.dart';
import '../features/detail/video_detail_screen.dart';
import '../features/phone/phone_shell.dart';
import '../features/player/youtube_player_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/tv/tv_shell.dart';
import '../l10n/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final gate = _AdminGateListenable(ref);
  ref.onDispose(gate.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: gate,
    redirect: (context, state) {
      final isAdmin = ref.read(isAdminProvider);
      final path = state.uri.path;
      final loggingIn = path == '/admin/login' || path == '/login';
      final adminArea = path.startsWith('/admin');

      // Catalog (and other /admin/* except login) require an admin session.
      if (adminArea && !loggingIn && !isAdmin) {
        return '/admin/login';
      }
      // Already signed in as admin → skip the entry form.
      if (loggingIn && isAdmin) {
        return '/admin/catalog';
      }

      // Phone must never land on the legacy /home TV alias (no bottom menu).
      // /home stays a TV-only synonym of /tv; phone viewports → /phone shell.
      if (path == '/home' && !FormFactor.isTvLayout(context)) {
        return '/phone';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // NoTransitionPage keeps a single bottom menu — Material page
      // transitions would briefly stack two PhoneShell NavigationBars.
      GoRoute(
        path: '/phone',
        name: 'phone',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: PhoneShell(),
        ),
      ),
      GoRoute(
        path: '/phone/watch',
        name: 'phone-watch',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: PhoneShell(initialIndex: 1),
        ),
      ),
      GoRoute(
        path: '/phone/profile',
        name: 'phone-profile',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: PhoneShell(initialIndex: 2),
        ),
      ),
      // Legacy alias — phone viewports redirect to /phone (see redirect above).
      // TV / leanback still renders [TvShell] here; prefer /tv for new links.
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const TvShell(),
      ),
      GoRoute(
        path: '/tv',
        name: 'tv',
        builder: (context, state) => const TvShell(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/catalog',
        name: 'admin-catalog',
        builder: (context, state) => const AdminCatalogScreen(),
      ),
      GoRoute(
        path: '/channel/:channelId',
        name: 'channel',
        builder: (context, state) {
          final raw = state.pathParameters['channelId'] ?? '';
          final channelId = Uri.decodeComponent(raw);
          final extra = state.extra;
          final fallbackName = extra is String ? extra : '';
          return ChannelBrowseScreen(
            channelId: channelId,
            fallbackName: fallbackName,
          );
        },
      ),
      GoRoute(
        path: '/detail',
        name: 'detail',
        builder: (context, state) {
          final extra = state.extra;
          final l10n = AppLocalizations.of(context);
          final item = extra is VideoItem
              ? extra
              : VideoItem(
                  id: '',
                  title: l10n.missingVideo,
                  channelName: '',
                  thumbnailUrl: '',
                );
          return VideoDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: '/play',
        name: 'play',
        builder: (context, state) {
          final extra = state.extra;
          final l10n = AppLocalizations.of(context);
          final item = extra is VideoItem
              ? extra
              : VideoItem(
                  id: '',
                  title: l10n.missingVideo,
                  channelName: '',
                  thumbnailUrl: '',
                );
          return YoutubePlayerScreen(item: item);
        },
      ),
    ],
    errorBuilder: (context, state) {
      // Localizations may be unavailable during early bootstrap.
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        body: Center(child: Text(l10n.routeError('${state.error}'))),
      );
    },
  );
});

/// Notifies [GoRouter] when admin session flips so redirects re-run.
class _AdminGateListenable extends ChangeNotifier {
  _AdminGateListenable(this._ref) {
    _sub = _ref.listen<bool>(isAdminProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
  late final ProviderSubscription<bool> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
