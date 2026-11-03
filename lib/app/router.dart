import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/video_item.dart';
import '../features/detail/video_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/phone/phone_shell.dart';
import '../features/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
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
      // TV leanback home (M0/M2) — preserved for Android TV / wide demos.
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/tv',
        name: 'tv',
        builder: (context, state) => const HomeScreen(),
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
