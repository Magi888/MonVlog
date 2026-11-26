import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes the app UI locale (`mn` / `en`).
///
/// **Default (documented):** Mongolian (`mn`) when no preference is saved.
/// MonVlog is a Mongolian community product (Monvlog.com / Монголчуудын нэгдэл);
/// English is available via the Profile (and login) language switch.
/// A saved `app_locale` preference always wins.
class LocaleController extends StateNotifier<Locale> {
  LocaleController({
    SharedPreferences? prefs,
    Locale? initial,
  })  : _prefsOverride = prefs,
        super(initial ?? defaultLocale);

  static const prefsKey = 'app_locale';
  static const supported = [Locale('mn'), Locale('en')];

  /// Product default when nothing is stored.
  static const defaultLocale = Locale('mn');

  final SharedPreferences? _prefsOverride;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _prefsOrGet() async {
    return _prefsOverride ?? (_prefs ??= await SharedPreferences.getInstance());
  }

  /// Load saved preference (or product default) into [state].
  Future<void> load() async {
    final prefs = await _prefsOrGet();
    final code = prefs.getString(prefsKey);
    state = localeFromCode(code) ?? defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = localeFromCode(locale.languageCode) ?? defaultLocale;
    state = normalized;
    final prefs = await _prefsOrGet();
    await prefs.setString(prefsKey, normalized.languageCode);
  }

  static Locale? localeFromCode(String? code) {
    if (code == 'mn') return const Locale('mn');
    if (code == 'en') return const Locale('en');
    return null;
  }

  static Locale resolveInitial(SharedPreferences prefs) {
    return localeFromCode(prefs.getString(prefsKey)) ?? defaultLocale;
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});
