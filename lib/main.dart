import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'auth/admin_auth_service.dart';
import 'billing/purchases_stub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Placeholder only — no RevenueCat API keys in M0.
  await PurchasesStub.configure();
  // Bootstrap admin password hash from compile-time ADMIN_PASSWORD (default or dart-define).
  await AdminAuthService().bootstrapFromDartDefine();
  runApp(const ProviderScope(child: MonVlogApp()));
}
