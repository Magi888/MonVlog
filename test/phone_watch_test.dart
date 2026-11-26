import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/app/theme.dart';
import 'package:monvlog/data/catalog_providers.dart';
import 'package:monvlog/data/catalog_repository.dart';
import 'package:monvlog/data/mock_catalog.dart';
import 'package:monvlog/data/models/curated_channel.dart';
import 'package:monvlog/features/phone/phone_shell.dart';
import 'package:monvlog/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    setTestLocaleEnglish();
  });

  testWidgets('Watch tab shows mock catalog shelves', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...localeOverrides(),
          homeCatalogProvider.overrideWith((ref) async {
            return CatalogSnapshot(
              shelves: MockCatalog.shelves,
              channels: const <CuratedChannel>[],
              source: CatalogSource.mock,
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
          home: const PhoneShell(initialIndex: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Featured'), findsOneWidget);
    expect(find.textContaining('Mock'), findsWidgets);
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('New from creators'), findsOneWidget);
  });
}
