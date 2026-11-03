import 'package:flutter/foundation.dart';

/// RevenueCat / StoreKit / Play Billing wrapper stub for M0.
///
/// Product (later): `monvlog_premium_monthly` @ **$3.99/month**
/// Entitlement: `premium`
///
/// Do not put real API keys here. Wire `purchases_flutter` in M4.
class PurchasesStub {
  static const String productId = 'monvlog_premium_monthly';
  static const String entitlementId = 'premium';
  static const String priceLabel = '\$3.99/month';

  /// Placeholder public SDK keys — replace via --dart-define / secrets in M4.
  static const String androidApiKeyPlaceholder = 'goog_REPLACE_ME';
  static const String iosApiKeyPlaceholder = 'appl_REPLACE_ME';

  static bool get isConfigured => _configured;
  static bool _configured = false;

  /// Always grants access in M0 so the TV shell is usable without billing.
  static bool get hasPremium => true;

  static Future<void> configure() async {
    // Intentionally does not call Purchases.configure — no secrets in M0.
    debugPrint(
      'PurchasesStub: configured (noop). '
      'Product $productId @ $priceLabel; entitlement $entitlementId. '
      'Keys: android=$androidApiKeyPlaceholder ios=$iosApiKeyPlaceholder',
    );
    _configured = true;
  }

  static Future<bool> restore() async {
    debugPrint('PurchasesStub.restore: noop → premium');
    return hasPremium;
  }
}
