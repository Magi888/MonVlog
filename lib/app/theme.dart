import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MonVlog brand + dual surfaces: phone (light, red/white) and TV (dark leanback).
class MonVlogTheme {
  // —— Brand (phone mockup priority) ——
  static const Color brandRed = Color(0xFFD32F2F);
  static const Color brandRedDeep = Color(0xFFB71C1C);
  static const Color navy = Color(0xFF0D1B2A);
  static const Color navySoft = Color(0xFF1B2838);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color memberGrey = Color(0xFF8A939E);
  static const Color softGrey = Color(0xFFF3F4F6);

  // —— Legacy TV dark tokens (leanback) ——
  static const Color bg = Color(0xFF121826);
  static const Color surface = Color(0xFF1B2436);
  static const Color accent = brandRed;
  static const Color onBg = Color(0xFFF5F0E8);
  static const Color muted = Color(0xFFB4BECD);

  static TextTheme _phoneTextTheme(TextTheme base) {
    final display = GoogleFonts.bebasNeue(color: navy, letterSpacing: 0.6);
    final body = GoogleFonts.manrope(color: navy);
    return base.copyWith(
      displayLarge: display.copyWith(fontSize: 56, fontWeight: FontWeight.w700),
      displayMedium: display.copyWith(fontSize: 40, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: navy,
        height: 1.15,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: navy,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: navy,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: navy,
      ),
      bodyLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      bodySmall: body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: memberGrey,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  /// Phone-first light theme — brand red, white surfaces, navy type.
  static ThemeData get phone {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: brandRed,
        onPrimary: cardWhite,
        secondary: navy,
        onSecondary: cardWhite,
        surface: cardWhite,
        onSurface: navy,
        error: brandRedDeep,
      ),
      scaffoldBackgroundColor: cardWhite,
    );

    return base.copyWith(
      textTheme: _phoneTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: navy,
        titleTextStyle: GoogleFonts.manrope(
          color: navy,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandRed,
          foregroundColor: cardWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandRed,
          side: const BorderSide(color: brandRed, width: 1.6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardWhite,
        indicatorColor: brandRed.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// TV-first dark theme: large type, high-contrast focus rings.
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
