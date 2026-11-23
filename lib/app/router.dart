import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/admin_auth_providers.dart';
import '../data/models/video_item.dart';
import '../features/admin/admin_catalog_screen.dart';
import '../features/admin/admin_login_screen.dart';
import '../features/detail/video_detail_screen.dart';
import '../features/phone/phone_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/tv/tv_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final gate = _AdminGateListenable(ref);
  ref.onDispose(gate.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: gate,
    redirect: (context, state) {
      final isAdmin = ref.read(isAdminProvider);
      final path = state.uri.path;
      final loggingIn = path == '/admin/login';
      final adminArea = path.startsWith('/admin');

      if (adminArea && !loggingIn && !isAdmin) {
        return '/admin/login';
      }
      if (loggingIn && isAdmin) {
        return '/admin/catalog';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/phone',
        name: 'phone',
        builder: (context, state) => const PhoneShell(),
      ),
      GoRoute(
        path: '/phone/watch',
        name: 'phone-watch',
        builder: (context, state) => const PhoneShell(initialIndex: 1),
      ),
      // Netflix-style TV leanback (Android TV / Google TV / Samsung living room).
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
        path: '/detail',
        name: 'detail',
        builder: (context, state) {
          final extra = state.extra;
          final item = extra is VideoItem
              ? extra
              : const VideoItem(
                  id: '',
                  title: 'Missing video',
                  channelName: '',
                  thumbnailUrl: '',
                );
          return VideoDetailScreen(item: item);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route error: ${state.error}')),
    ),
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
