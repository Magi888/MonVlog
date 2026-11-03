import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monvlog/app/app.dart';

void main() {
  testWidgets('MonVlog splash shows brand then home shelves', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MonVlogApp()),
    );
    expect(find.text('MonVlog'), findsOneWidget);
    expect(find.textContaining('Mongolian vlogs'), findsOneWidget);

    // Advance past splash gate (1.4s) and settle navigation to home.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Featured'), findsOneWidget);
    expect(find.text('New from creators'), findsOneWidget);
  });
}
