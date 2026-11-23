import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/app/theme.dart';
import 'package:monvlog/data/catalog_providers.dart';
import 'package:monvlog/data/catalog_repository.dart';
import 'package:monvlog/data/mock_catalog.dart';
import 'package:monvlog/data/models/curated_channel.dart';
import 'package:monvlog/features/tv/tv_shell.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('TV shell shows left rail and mock shelves', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeCatalogProvider.overrideWith((ref) async {
            return CatalogSnapshot(
              shelves: MockCatalog.shelves,
              channels: const <CuratedChannel>[],
              source: CatalogSource.mock,
            );
          }),
        ],
        child: MaterialApp(
          theme: MonVlogTheme.dark,
          home: const TvShell(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Creators'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('FEATURED'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);
    // Scroll to bring lower shelves into the lazy sliver cache.
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('New from creators'), findsOneWidget);
  });
}
