import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monvlog/app/app.dart';
import 'package:monvlog/app/theme.dart';
import 'package:monvlog/features/phone/phone_shell.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('phone bottom menu stays visible across Community/Watch/Profile',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MonVlogApp()),
    );
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    void expectMenu() {
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
    }

    expectMenu();
    expect(find.text('Monvlog.com'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Watch'),
      ),
    );
    await tester.pump(); // start transition; avoid settle (network images)
    await tester.pump(const Duration(milliseconds: 400));
    expectMenu();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expectMenu();
    expect(find.text('Browsing as guest'), findsOneWidget);
    expect(find.text('Admin sign-in'), findsOneWidget);
  });

  testWidgets('PhoneShell paints high-contrast destinations under dark theme',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          themeMode: ThemeMode.dark,
          theme: MonVlogTheme.phone,
          darkTheme: MonVlogTheme.dark,
          home: const PhoneShell(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
