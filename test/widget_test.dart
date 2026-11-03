import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monvlog/app/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('MonVlog splash shows brand then phone community mockup',
      (tester) async {
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
    expect(find.text('Community'), findsWidgets);
    expect(find.text('Watch'), findsOneWidget);
  });
}
