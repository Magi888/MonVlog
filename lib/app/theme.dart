import 'package:flutter/material.dart';

/// TV-first dark theme: large type, high-contrast focus rings.
class MonVlogTheme {
  static const Color bg = Color(0xFF121826);
  static const Color surface = Color(0xFF1B2436);
  static const Color accent = Color(0xFFE85D3A);
  static const Color onBg = Color(0xFFF5F0E8);
  static const Color muted = Color(0xFFB4BECD);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        onPrimary: onBg,
        secondary: muted,
        onSurface: onBg,
      ),
      scaffoldBackgroundColor: bg,
      focusColor: accent.withValues(alpha: 0.35),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: onBg,
        displayColor: onBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: onBg,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
