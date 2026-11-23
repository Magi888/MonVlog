import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monvlog/app/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MonVlog splash shows brand then phone community mockup',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MonVlogApp()),
    );
    expect(find.text('MonVlog'), findsWidgets);
    expect(find.textContaining('Монголчуудын нэгдэл'), findsOneWidget);

    // Advance past splash gate (1.4s) and settle navigation + animations.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Monvlog.com'), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    expect(find.text('Оператор'), findsOneWidget);
    expect(find.text('МОНГОЛ ВЛОГ & КОНТЕНТ'), findsOneWidget);
    expect(find.text('All Video Channels'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
  });
}
