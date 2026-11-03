import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _gate();
  }

  Future<void> _gate() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    // M0: always home. M4: route to paywall when !PurchasesStub.hasPremium.
    if (PurchasesStub.hasPremium) {
      context.go('/home');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1420), MonVlogTheme.bg, Color(0xFF1A1020)],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MonVlog',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: MonVlogTheme.onBg,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Mongolian vlogs for the living room',
                style: TextStyle(
                  fontSize: 20,
                  color: MonVlogTheme.muted,
                ),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: MonVlogTheme.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
