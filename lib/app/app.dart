import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class MonVlogApp extends ConsumerWidget {
  const MonVlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'MonVlog',
      debugShowCheckedModeBanner: false,
      // Phone mockup is the primary visual demo; TV screens still use dark tokens.
      theme: MonVlogTheme.phone,
      darkTheme: MonVlogTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
