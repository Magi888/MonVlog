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
      // Dark community + Netflix TV share dark Mode; phone ThemeData carries
      // coral accents for the Wix-like community shell.
      theme: MonVlogTheme.phone,
      darkTheme: MonVlogTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
