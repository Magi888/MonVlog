import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/app/theme.dart';
import 'package:monvlog/features/phone/phone_shell.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Watch tab shows mock catalog shelves', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MonVlogTheme.phone,
          home: const PhoneShell(initialIndex: 1),
        ),
      ),
    );

    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Featured').evaluate().isNotEmpty) break;
    }

    expect(find.text('Featured'), findsOneWidget);
    expect(find.text('New from creators'), findsOneWidget);
    expect(find.textContaining('Mock'), findsWidgets);
  });
}
