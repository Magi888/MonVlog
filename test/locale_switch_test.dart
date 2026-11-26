import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monvlog/locale/locale_controller.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    setTestLocaleEnglish();
  });

  test('LocaleController defaults to Mongolian product locale', () {
    expect(LocaleController.defaultLocale, const Locale('mn'));
    expect(LocaleController.localeFromCode(null), isNull);
    expect(LocaleController.localeFromCode('mn'), const Locale('mn'));
    expect(LocaleController.localeFromCode('en'), const Locale('en'));
  });

  test('LocaleController persists choice in shared_preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs: prefs);
    expect(controller.state, const Locale('mn'));

    await controller.setLocale(const Locale('en'));
    expect(controller.state, const Locale('en'));
    expect(prefs.getString(LocaleController.prefsKey), 'en');

    await controller.setLocale(const Locale('mn'));
    expect(prefs.getString(LocaleController.prefsKey), 'mn');
  });

  testWidgets('Profile language switch flips shell labels mn ↔ en',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpMonVlogApp(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Community'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    await tester.tap(find.text('Монгол'));
    await tester.pumpAndSettle();

    expect(find.text('Нэгдэл'), findsOneWidget);
    expect(find.text('Үзэх'), findsOneWidget);
    expect(find.text('Профайл'), findsWidgets);
    expect(find.text('Хэл'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleController.prefsKey), 'en');
  });
}
