import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/auth/admin_config.dart';
import 'package:monvlog/features/admin/admin_login_screen.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    setTestLocaleEnglish();
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/admin/login',
      routes: [
        GoRoute(
          path: '/admin/login',
          builder: (_, __) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/phone',
          builder: (_, __) => const Scaffold(body: Text('phone-home')),
        ),
        GoRoute(
          path: '/tv',
          builder: (_, __) => const Scaffold(body: Text('tv-home')),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('legacy-home')),
        ),
        GoRoute(
          path: '/admin/catalog',
          builder: (_, __) => const Scaffold(body: Text('admin-catalog')),
        ),
      ],
    );
  }

  testWidgets('login screen shows branded controls without plaintext password',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testAppRouter(routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('MonVlog'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text(AdminConfig.seedEmail), findsOneWidget);
    expect(find.textContaining('seeded admin'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    // Password field starts empty — never prefilled from source.
    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields.length, greaterThanOrEqualTo(2));
    expect(fields[1].controller?.text ?? '', isEmpty);
    expect(AdminConfig.passwordFromDefine, isNotEmpty);
  });

  testWidgets('guest continue on phone viewport goes to /phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testAppRouter(routerConfig: buildRouter()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(find.text('phone-home'), findsOneWidget);
  });

  testWidgets('guest continue on TV viewport goes to /tv', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testAppRouter(routerConfig: buildRouter()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(find.text('tv-home'), findsOneWidget);
    expect(find.text('legacy-home'), findsNothing);
  });
}
