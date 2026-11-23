import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/form_factor.dart';
import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../auth/admin_config.dart';
import '../phone/widgets/monvlog_logo_mark.dart';

/// Branded MonVlog entry / admin login.
///
/// Admin (`maag888@gmail.com` + `ADMIN_PASSWORD` dart-define) → catalog.
/// Everyone else can **Continue as guest** into home/community (read-only).
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
  String? _error;

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
  }

  @override
  void dispose() {
    _motion.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _guestDestination(BuildContext context) {
    return FormFactor.isTvLayout(context) ? '/home' : '/phone';
  }

  void _continueAsGuest() {
    context.go(_guestDestination(context));
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    final result = await ref.read(adminSessionProvider.notifier).login(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.success) {
      context.go('/admin/catalog');
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(adminSessionProvider);
    if (session.valueOrNull?.isAdmin == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/admin/catalog');
      });
    }

    final canPop = context.canPop();

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
              // Soft brand glow behind the mark.
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
                    tooltip: 'Back',
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
                                'Монголчуудын нэгдэл',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: MonVlogTheme.onBg,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Admin sign-in or browse as a guest',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: MonVlogTheme.muted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                style: GoogleFonts.manrope(
                                  color: MonVlogTheme.onBg,
                                ),
                                decoration: _decoration(
                                  label: 'Email',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email required';
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
                                  label: 'Password',
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
                                    _submit();
                                  }
                                },
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password required';
                                  }
                                  return null;
                                },
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
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
                                          _submit();
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
                                        'Login',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
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
                                  'Continue as guest',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Guests browse Community & Watch read-only. '
                                'Only the seeded admin can curate the catalog. '
                                'Password via --dart-define=ADMIN_PASSWORD '
                                '(never commit).',
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
