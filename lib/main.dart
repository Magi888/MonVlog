import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'billing/purchases_stub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Placeholder only — no RevenueCat API keys in M0.
  await PurchasesStub.configure();
  runApp(const ProviderScope(child: MonVlogApp()));
}
