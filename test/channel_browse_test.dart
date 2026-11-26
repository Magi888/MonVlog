import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monvlog/app/theme.dart';
import 'package:monvlog/data/catalog_providers.dart';
import 'package:monvlog/data/catalog_repository.dart';
import 'package:monvlog/data/models/curated_channel.dart';
import 'package:monvlog/data/models/shelf.dart';
import 'package:monvlog/data/models/video_item.dart';
import 'package:monvlog/features/channel/channel_browse_screen.dart';
import 'package:monvlog/features/home/widgets/poster_card.dart';
import 'package:monvlog/l10n/app_localizations.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    setTestLocaleEnglish();
  });

  testWidgets('Channel browse shows shelves and titles', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const channelId = 'UCQXxhQHalYjwMictp1lUbtg';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...localeOverrides(),
          channelCatalogProvider(channelId).overrideWith((ref) async {
            return const ChannelCatalogSnapshot(
              channel: CuratedChannel(
                channelId: channelId,
                displayName: 'Gremix',
                category: 'daily',
                verified: true,
                handle: '@GremixBn',
              ),
              shelves: [
                Shelf(
                  id: 'uploads',
                  title: 'Latest uploads',
                  items: [
                    VideoItem(
                      id: 'v1',
                      title: 'Morning walk',
                      channelName: 'Gremix',
                      channelId: channelId,
                      thumbnailUrl: 'https://picsum.photos/seed/t/480/270',
                      durationLabel: '10:00',
                    ),
                  ],
                ),
              ],
              source: CatalogSource.mock,
              message: 'test',
            );
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: MonVlogTheme.phone,
          home: const ChannelBrowseScreen(
            channelId: channelId,
            fallbackName: 'Gremix',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gremix'), findsWidgets);
    expect(find.text('Latest uploads'), findsOneWidget);
    expect(find.text('Morning walk'), findsOneWidget);
  });

  testWidgets('TV channel browse uses focusable PosterCard shelves',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const channelId = 'UCQXxhQHalYjwMictp1lUbtg';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...localeOverrides(),
          channelCatalogProvider(channelId).overrideWith((ref) async {
            return const ChannelCatalogSnapshot(
              channel: CuratedChannel(
                channelId: channelId,
                displayName: 'Gremix',
                category: 'daily',
                verified: true,
                handle: '@GremixBn',
              ),
              shelves: [
                Shelf(
                  id: 'uploads',
                  title: 'Latest uploads',
                  items: [
                    VideoItem(
                      id: 'v1',
                      title: 'Morning walk',
                      channelName: 'Gremix',
                      channelId: channelId,
                      thumbnailUrl: 'https://picsum.photos/seed/t/480/270',
                      durationLabel: '10:00',
                    ),
                  ],
                ),
              ],
              source: CatalogSource.mock,
              message: 'test',
            );
          }),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: MonVlogTheme.dark,
          home: const ChannelBrowseScreen(
            channelId: channelId,
            fallbackName: 'Gremix',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Latest uploads'), findsOneWidget);
    expect(find.text('Morning walk'), findsOneWidget);
    expect(find.byType(PosterCard), findsOneWidget);
  });
}
