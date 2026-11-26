import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../locale/locale_controller.dart';
import 'router.dart';
import 'theme.dart';

class MonVlogApp extends ConsumerWidget {
  const MonVlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: 'MonVlog',
      debugShowCheckedModeBanner: false,
      // Dark community + Netflix TV share dark Mode. Both themes carry a
      // high-contrast NavigationBarTheme so the phone bottom menu stays
      // readable (Community / Watch / Profile) after splash → guest path.
      theme: MonVlogTheme.phone,
      darkTheme: MonVlogTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
