import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/app/app.dart';
import 'package:monvlog/app/router.dart';
import 'package:monvlog/features/phone/phone_shell.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    setTestLocaleEnglish();
  });

  testWidgets('/home on phone viewport redirects into PhoneShell with Profile',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpMonVlogApp(tester);
    // Advance past splash timer onto the entry login, then hit the legacy alias.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 100));

    // Use the live GoRouter from the app's ProviderScope.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonVlogApp)),
    );
    container.read(appRouterProvider).go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PhoneShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Community'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Watch'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
      findsOneWidget,
    );
    expect(find.text('MVP shell'), findsNothing);
    expect(container.read(appRouterProvider).state.uri.path, '/phone');
  });

  testWidgets('guest path from splash lands on /phone with Profile selectable',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpMonVlogApp(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Continue as guest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Watch'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('MVP shell'), findsNothing);
    // Phone Watch never shows the retired M0 "MVP shell" chip.
    expect(find.textContaining('billing stubbed'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Browsing as guest'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
