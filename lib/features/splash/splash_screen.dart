import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../billing/purchases_stub.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _gate();
  }

  Future<void> _gate() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    // M4: if (!PurchasesStub.hasPremium) → paywall.
    assert(() {
      // Keep billing stub wired until RevenueCat gate lands.
      return PurchasesStub.hasPremium || !PurchasesStub.hasPremium;
    }());
    // Entry gate: branded login. Admin → catalog; guest → /phone shell.
    context.go('/admin/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Match splash ref: crisp white MONVLOG box ~58% width, readable tagline.
    final logoWidth = (width * 0.58).clamp(240.0, 440.0);
    final taglineSize = (width * 0.038).clamp(15.0, 20.0);

    return Scaffold(
      backgroundColor: MonVlogTheme.brandRed,
      body: ColoredBox(
        color: MonVlogTheme.brandRed,
        child: SizedBox.expand(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/brand/monvlog-logo-box.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Watch anywhere, make anywhere',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: taglineSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.25,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
