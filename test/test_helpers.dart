import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monvlog/app/app.dart';
import 'package:monvlog/l10n/app_localizations.dart';
import 'package:monvlog/locale/locale_controller.dart';

/// Prefer English in widget tests so existing string assertions stay stable.
void setTestLocaleEnglish() {
  SharedPreferences.setMockInitialValues({
    LocaleController.prefsKey: 'en',
  });
}

List<Override> localeOverrides([Locale locale = const Locale('en')]) {
  return [
    localeControllerProvider.overrideWith(
      (ref) => LocaleController(initial: locale),
    ),
  ];
}

Future<void> pumpMonVlogApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: localeOverrides(locale),
      child: const MonVlogApp(),
    ),
  );
}

/// MaterialApp wrapper with l10n for screens tested outside [MonVlogApp].
Widget testApp({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode themeMode = ThemeMode.dark,
}) {
  return ProviderScope(
    overrides: localeOverrides(locale),
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: home,
    ),
  );
}

Widget testAppRouter({
  required dynamic routerConfig,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: localeOverrides(locale),
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: routerConfig,
    ),
  );
}
