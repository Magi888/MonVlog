import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../auth/admin_config.dart';

/// Email + password login for the seeded admin identity.
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl = TextEditingController(text: AdminConfig.seedEmail);
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _busy = false;
  var _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: MonVlogTheme.communityBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Admin',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/phone');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'MonVlog',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 48,
                      color: MonVlogTheme.brandRed,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catalog admin sign-in',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: MonVlogTheme.muted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: GoogleFonts.manrope(color: MonVlogTheme.onBg),
                    decoration: _decoration('Email'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    style: GoogleFonts.manrope(color: MonVlogTheme.onBg),
                    decoration: _decoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: MonVlogTheme.muted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onFieldSubmitted: (_) {
                      if (_formKey.currentState?.validate() ?? false) {
                        _submit();
                      }
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password required';
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: GoogleFonts.manrope(
                        color: MonVlogTheme.coral,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _submit();
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: MonVlogTheme.brandRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign in',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Password is supplied via --dart-define=ADMIN_PASSWORD '
                    '(bootstrapped into secure storage on first run). '
                    'Never commit the password.',
                    style: GoogleFonts.manrope(
                      color: MonVlogTheme.muted,
                      fontSize: 12,
                      height: 1.4,
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

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(color: MonVlogTheme.muted),
      filled: true,
      fillColor: MonVlogTheme.communitySurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
