import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    setTestLocaleEnglish();
  });

  testWidgets('MonVlog splash shows brand then entry login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpMonVlogApp(tester);
    expect(find.text('Watch anywhere, make anywhere'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/brand/monvlog-logo-box.png',
      ),
      findsOneWidget,
    );

    // Advance past splash gate (1.4s) and settle navigation + animations.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('MonVlog'), findsWidgets);
    expect(find.text('Монголчуудын нэгдэл'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Continue as guest opens phone community', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpMonVlogApp(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Monvlog.com'), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Browsing as guest'), findsOneWidget);
    expect(find.text('Continue as guest'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });
}
