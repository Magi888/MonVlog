import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/app/theme.dart';
import 'package:monvlog/data/models/video_item.dart';
import 'package:monvlog/features/detail/video_detail_screen.dart';
import 'package:monvlog/features/player/youtube_player_screen.dart';
import 'package:monvlog/l10n/app_localizations.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    setTestLocaleEnglish();
  });

  const item = VideoItem(
    id: 'dQw4w9WgXcQ',
    title: 'Mock travel vlog',
    channelName: 'Gremix',
    thumbnailUrl: '',
    description: 'A mock description for detail.',
    durationLabel: '12:34',
  );

  testWidgets('phone detail Play opens /play (no M3 snackbar)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/detail',
          builder: (_, __) => const VideoDetailScreen(item: item),
        ),
        GoRoute(
          path: '/play',
          builder: (_, state) {
            final extra = state.extra;
            final video = extra is VideoItem ? extra : item;
            // Avoid embedding the native WebView in unit tests.
            return Scaffold(
              body: Text('player:${video.id}'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: localeOverrides(),
        child: MaterialApp.router(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: MonVlogTheme.phone,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('M3'), findsNothing);
    expect(find.text('Play'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Play'));
    await tester.pumpAndSettle();

    expect(find.text('player:dQw4w9WgXcQ'), findsOneWidget);
    expect(find.textContaining('M3'), findsNothing);
  });

  testWidgets('player screen shows missing-id message when id empty',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const missing = VideoItem(
      id: '',
      title: 'Broken item',
      channelName: '',
      thumbnailUrl: '',
    );

    await tester.pumpWidget(
      testApp(
        theme: MonVlogTheme.phone,
        home: const YoutubePlayerScreen(item: missing),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('missing YouTube id'),
      findsOneWidget,
    );
    expect(find.textContaining('M3'), findsNothing);
  });

  testWidgets('Open in YouTube remains on detail as secondary action',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        theme: MonVlogTheme.phone,
        home: const VideoDetailScreen(item: item),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open in YouTube'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Open in YouTube'), findsOneWidget);
  });
}
