import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MonVlog brand + dual surfaces: phone community (Wix-like dark) and Netflix TV.
class MonVlogTheme {
  // —— Brand ——
  /// Official logo / splash red (`assets/brand/monvlog-logo.png`).
  static const Color brandRed = Color(0xFFE71616);
  static const Color brandRedDeep = Color(0xFFB71C1C);
  static const Color coral = Color(0xFFE58A8A);
  static const Color coralSoft = Color(0xFFF48FB1);

  // —— Phone community (Wix Spaces dark shell) ——
  static const Color communityBg = Color(0xFF121212);
  static const Color communitySurface = Color(0xFF1C1E21);
  static const Color communityElevated = Color(0xFF2A2C30);
  static const Color navy = Color(0xFF0D1B2A);
  static const Color navySoft = Color(0xFF1B2838);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color memberGrey = Color(0xFF9E9E9E);
  static const Color softGrey = Color(0xFFF3F4F6);

  // —— Netflix-style TV / Watch ——
  static const Color bg = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF16161D);
  static const Color rail = Color(0xFF0F0F14);
  static const Color accent = brandRed;
  static const Color onBg = Color(0xFFF5F5F7);
  static const Color muted = Color(0xFFA0A0B0);
  static const Color focusRing = Color(0xFFFFFFFF);

  static TextTheme _phoneTextTheme(TextTheme base) {
    final display = GoogleFonts.bebasNeue(color: onBg, letterSpacing: 0.6);
    final body = GoogleFonts.manrope(color: onBg);
    return base.copyWith(
      displayLarge: display.copyWith(fontSize: 56, fontWeight: FontWeight.w700),
      displayMedium: display.copyWith(fontSize: 40, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: onBg,
        height: 1.15,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onBg,
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

  /// Phone community dark theme — Wix Spaces Monvlog.com look.
  static ThemeData get phone {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: coral,
        onPrimary: Colors.white,
        secondary: brandRed,
        onSecondary: Colors.white,
        surface: communitySurface,
        onSurface: onBg,
        error: brandRedDeep,
      ),
      scaffoldBackgroundColor: communityBg,
    );

    return base.copyWith(
      textTheme: _phoneTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: onBg,
        titleTextStyle: GoogleFonts.manrope(
          color: onBg,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white70, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      navigationBarTheme: _phoneNavigationBarTheme,
    );
  }

  /// High-contrast phone bottom menu — works under [ThemeMode.dark] too.
  static NavigationBarThemeData get _phoneNavigationBarTheme {
    return NavigationBarThemeData(
      backgroundColor: communityBg,
      surfaceTintColor: Colors.transparent,
      indicatorColor: coral.withValues(alpha: 0.22),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? coral : onBg,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? coral : onBg,
        );
      }),
    );
  }

  /// TV Netflix dark theme: large type, high-contrast focus rings.
  /// Includes the phone [NavigationBarTheme] so a dark [ThemeMode] cannot
  /// wash out Community / Watch / Profile labels (dark-on-dark).
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
        onSurfaceVariant: onBg,
      ),
      scaffoldBackgroundColor: bg,
      focusColor: focusRing.withValues(alpha: 0.35),
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: onBg,
        displayColor: onBg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.bebasNeue(
          color: onBg,
          fontSize: 32,
          letterSpacing: 1.2,
        ),
      ),
      navigationBarTheme: _phoneNavigationBarTheme,
    );
  }
}
