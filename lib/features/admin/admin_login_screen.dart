import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/form_factor.dart';
import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../auth/admin_auth_service.dart';
import '../../auth/admin_config.dart';
import '../../l10n/app_localizations.dart';
import '../../locale/language_switch.dart';
import '../phone/widgets/monvlog_logo_mark.dart';

/// Branded MonVlog entry / admin login.
///
/// Admin (`maag888@gmail.com` + password) → catalog.
/// After one password login, optional local passkey / biometric unlock.
/// Everyone else can **Continue as guest** into the phone shell (read-only).
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: AdminConfig.seedEmail);
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _busy = false;
  var _obscure = true;
  String? _errorCode;

  /// Device can unlock and admin previously opted in.
  var _biometricReady = false;

  /// Prefer the biometric button when ready; user can fall back to password.
  var _preferBiometric = true;

  /// Suppresses the “already admin → catalog” redirect while the post-login
  /// passkey offer dialog is open.
  var _suppressAdminRedirect = false;

  late final AnimationController _motion;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _motion, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _motion, curve: Curves.easeOutCubic));
    _motion.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBiometricState());
  }

  Future<void> _refreshBiometricState() async {
    final auth = ref.read(adminAuthServiceProvider);
    final ready = await auth.canBiometricUnlock;
    if (!mounted) return;
    setState(() {
      _biometricReady = ready;
      if (ready) _preferBiometric = true;
    });
  }

  @override
  void dispose() {
    _motion.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _guestDestination(BuildContext context) {
    // Phone always enters the Community/Watch/Profile shell — never /home.
    return FormFactor.isTvLayout(context) ? '/tv' : '/phone';
  }

  void _continueAsGuest() {
    context.go(_guestDestination(context));
  }

  String _localizeError(AppLocalizations l10n, String? code) {
    switch (code) {
      case AdminAuthResult.onlySeededAdmin:
        return l10n.authOnlySeededAdmin;
      case AdminAuthResult.passwordRequired:
        return l10n.authPasswordRequired;
      case AdminAuthResult.invalidCredentials:
        return l10n.authInvalidCredentials;
      case AdminAuthResult.biometricNotEnabled:
        return l10n.authBiometricNotEnabled;
      case AdminAuthResult.biometricUnavailable:
        return l10n.authBiometricUnavailable;
      case AdminAuthResult.biometricFailed:
        return l10n.authBiometricFailed;
      case AdminAuthResult.biometricNotAdmin:
        return l10n.authBiometricNotAdmin;
      default:
        return code ?? '';
    }
  }

  Future<void> _goCatalogAfterLogin({required bool offerPasskey}) async {
    if (!mounted) return;
    _suppressAdminRedirect = true;
    try {
      if (offerPasskey) {
        final offered = await _maybeOfferPasskey();
        if (!mounted) return;
        if (offered && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).passkeyEnabledSnack),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      if (!mounted) return;
      context.go('/admin/catalog');
    } finally {
      _suppressAdminRedirect = false;
    }
  }

  /// Returns true when the user enabled biometric unlock.
  Future<bool> _maybeOfferPasskey() async {
    final auth = ref.read(adminAuthServiceProvider);
    if (await auth.isBiometricUnlockEnabled) return false;
    if (!await auth.canUseDeviceUnlock) return false;
    if (!mounted) return false;

    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: MonVlogTheme.communitySurface,
          title: Text(
            l10n.passkeyOfferTitle,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.onBg,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            l10n.passkeyOfferBody,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.muted,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                l10n.passkeyOfferNotNow,
                style: GoogleFonts.manrope(color: MonVlogTheme.muted),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: MonVlogTheme.brandRed,
              ),
              child: Text(
                l10n.passkeyOfferEnable,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (choice != true || !mounted) return false;

    final result = await ref.read(adminSessionProvider.notifier).enableBiometricUnlock(
          localizedReason: l10n.passkeyPromptEnable,
        );
    if (!mounted) return false;
    if (!result.success) {
      setState(() => _errorCode = result.message);
      return false;
    }
    await _refreshBiometricState();
    return true;
  }

  Future<void> _submitPassword() async {
    setState(() {
      _errorCode = null;
      _busy = true;
      // Hold catalog redirect until the passkey offer finishes.
      _suppressAdminRedirect = true;
    });
    final result = await ref.read(adminSessionProvider.notifier).login(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.success) {
      await _goCatalogAfterLogin(offerPasskey: true);
    } else {
      setState(() {
        _errorCode = result.message;
        _suppressAdminRedirect = false;
      });
    }
  }

  Future<void> _submitBiometric() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _errorCode = null;
      _busy = true;
      _suppressAdminRedirect = true;
    });
    final result = await ref.read(adminSessionProvider.notifier).unlockWithBiometric(
          localizedReason: l10n.passkeyPromptUnlock,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.success) {
      await _goCatalogAfterLogin(offerPasskey: false);
    } else {
      setState(() {
        _errorCode = result.message;
        // Soft-fail into password form so the user is never stuck.
        _preferBiometric = false;
        _suppressAdminRedirect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(adminSessionProvider);
    if (!_suppressAdminRedirect && session.valueOrNull?.isAdmin == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_suppressAdminRedirect) {
          context.go('/admin/catalog');
        }
      });
    }

    final canPop = context.canPop();
    final showBiometricPrimary = _biometricReady && _preferBiometric;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A0A0A),
              MonVlogTheme.communityBg,
              Color(0xFF0A0A0C),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -40,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            MonVlogTheme.brandRed.withValues(alpha: 0.28),
                            MonVlogTheme.brandRed.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (canPop)
                Positioned(
                  top: 4,
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: MonVlogTheme.onBg,
                    tooltip: l10n.back,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        _continueAsGuest();
                      }
                    },
                  ),
                ),
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(child: MonVlogLogoMark(size: 88)),
                              const SizedBox(height: 20),
                              Text(
                                'MonVlog',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 52,
                                  color: MonVlogTheme.brandRed,
                                  letterSpacing: 1.4,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.taglineUnion,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: MonVlogTheme.onBg,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.loginSubtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: MonVlogTheme.muted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (showBiometricPrimary) ...[
                                FilledButton.icon(
                                  onPressed: _busy ? null : _submitBiometric,
                                  icon: const Icon(Icons.fingerprint_rounded),
                                  label: _busy
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          l10n.unlockWithPasskey,
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: MonVlogTheme.brandRed,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: MonVlogTheme
                                        .brandRed
                                        .withValues(alpha: 0.45),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                                if (_errorCode != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _localizeError(l10n, _errorCode),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.manrope(
                                      color: MonVlogTheme.coral,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => setState(() {
                                            _preferBiometric = false;
                                            _errorCode = null;
                                          }),
                                  child: Text(
                                    l10n.usePasswordInstead,
                                    style: GoogleFonts.manrope(
                                      color: MonVlogTheme.onBg,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  style: GoogleFonts.manrope(
                                    color: MonVlogTheme.onBg,
                                  ),
                                  decoration: _decoration(
                                    label: l10n.email,
                                    icon: Icons.mail_outline_rounded,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return l10n.emailRequired;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscure,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  style: GoogleFonts.manrope(
                                    color: MonVlogTheme.onBg,
                                  ),
                                  decoration: _decoration(
                                    label: l10n.password,
                                    icon: Icons.lock_outline_rounded,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: MonVlogTheme.muted,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _submitPassword();
                                    }
                                  },
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return l10n.passwordRequired;
                                    }
                                    return null;
                                  },
                                ),
                                if (_errorCode != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _localizeError(l10n, _errorCode),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.manrope(
                                      color: MonVlogTheme.coral,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            _submitPassword();
                                          }
                                        },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: MonVlogTheme.brandRed,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: MonVlogTheme
                                        .brandRed
                                        .withValues(alpha: 0.45),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _busy
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          l10n.login,
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                                if (_biometricReady) ...[
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : () => setState(
                                              () => _preferBiometric = true,
                                            ),
                                    icon: const Icon(
                                      Icons.fingerprint_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      l10n.unlockWithPasskey,
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: MonVlogTheme.onBg,
                                    ),
                                  ),
                                ],
                              ],
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _busy ? null : _continueAsGuest,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: MonVlogTheme.onBg,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.28),
                                    width: 1.4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  l10n.continueAsGuest,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const LanguageSwitchTile(compact: true),
                              const SizedBox(height: 16),
                              Text(
                                l10n.loginFooter,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: MonVlogTheme.muted,
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(color: MonVlogTheme.muted),
      prefixIcon: Icon(icon, color: MonVlogTheme.muted, size: 22),
      filled: true,
      fillColor: MonVlogTheme.communitySurface.withValues(alpha: 0.92),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: MonVlogTheme.brandRed,
          width: 1.5,
        ),
      ),
    );
  }
}
