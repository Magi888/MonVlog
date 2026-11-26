import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../auth/admin_config.dart';
import '../../l10n/app_localizations.dart';
import '../../locale/language_switch.dart';

/// Guest / account tab — Wix Spaces “My Profile” equivalent for phone.
/// Guests and admins both get the language switch here.
class PhoneProfileScreen extends ConsumerStatefulWidget {
  const PhoneProfileScreen({super.key});

  @override
  ConsumerState<PhoneProfileScreen> createState() => _PhoneProfileScreenState();
}

class _PhoneProfileScreenState extends ConsumerState<PhoneProfileScreen> {
  var _biometricSupported = false;
  var _biometricEnabled = false;
  var _biometricBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBiometric());
  }

  Future<void> _refreshBiometric() async {
    final auth = ref.read(adminAuthServiceProvider);
    final supported = await auth.canUseDeviceUnlock;
    final enabled = await auth.isBiometricUnlockEnabled;
    if (!mounted) return;
    setState(() {
      _biometricSupported = supported;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _toggleBiometric(bool enable) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _biometricBusy = true);
    final notifier = ref.read(adminSessionProvider.notifier);
    if (enable) {
      final result = await notifier.enableBiometricUnlock(
        localizedReason: l10n.passkeyPromptEnable,
      );
      if (!mounted) return;
      if (result.success) {
        setState(() => _biometricEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passkeyEnabledSnack),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await notifier.disableBiometricUnlock();
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
    }
    if (mounted) setState(() => _biometricBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(adminSessionProvider).valueOrNull;
    final isAdmin = session?.isAdmin == true;
    final top = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: MonVlogTheme.communityBg,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, top + 20, 20, 32),
        children: [
          Text(
            l10n.profileTitle,
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: MonVlogTheme.onBg,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin ? l10n.catalogAdminSignedIn : l10n.browsingAsGuest,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: MonVlogTheme.muted,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: MonVlogTheme.communitySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: MonVlogTheme.brandRed.withValues(alpha: 0.2),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_outline,
                    color: MonVlogTheme.coral,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin ? AdminConfig.seedEmail : l10n.guest,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MonVlogTheme.onBg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAdmin ? l10n.adminRole : l10n.watchOnlyAccess,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: MonVlogTheme.memberGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.sectionAccount,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MonVlogTheme.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: isAdmin
                ? Icons.video_library_outlined
                : Icons.login_rounded,
            label: isAdmin ? l10n.openCatalogAdmin : l10n.adminSignIn,
            onTap: () => context.go(
              isAdmin ? '/admin/catalog' : '/admin/login',
            ),
          ),
          if (isAdmin && _biometricSupported)
            _BiometricToggleTile(
              enabled: _biometricEnabled,
              busy: _biometricBusy,
              title: l10n.biometricUnlockToggle,
              subtitle: l10n.biometricUnlockSubtitle,
              onChanged: _toggleBiometric,
            ),
          if (isAdmin)
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: l10n.signOutToGuest,
              onTap: () async {
                await ref.read(adminSessionProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.signedOutGuestSnack),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          const SizedBox(height: 20),
          Text(
            l10n.sectionApp,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MonVlogTheme.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          const LanguageSwitchTile(),
          _ProfileTile(
            icon: Icons.info_outline_rounded,
            label: l10n.aboutMonVlog,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MonVlog',
                applicationVersion: '1.0.0',
                applicationLegalese: l10n.taglineUnion,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BiometricToggleTile extends StatelessWidget {
  const _BiometricToggleTile({
    required this.enabled,
    required this.busy,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final bool enabled;
  final bool busy;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: MonVlogTheme.communitySurface,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.fingerprint_rounded,
                color: MonVlogTheme.onBg,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MonVlogTheme.onBg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: MonVlogTheme.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: busy ? null : onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: MonVlogTheme.brandRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: MonVlogTheme.communitySurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: MonVlogTheme.onBg, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: MonVlogTheme.onBg,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: MonVlogTheme.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
