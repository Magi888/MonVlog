import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../auth/admin_config.dart';

/// Guest / account tab — Wix Spaces “My Profile” equivalent for phone.
class PhoneProfileScreen extends ConsumerWidget {
  const PhoneProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(adminSessionProvider).valueOrNull;
    final isAdmin = session?.isAdmin == true;
    final top = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: MonVlogTheme.communityBg,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, top + 20, 20, 32),
        children: [
          Text(
            'Profile',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: MonVlogTheme.onBg,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin ? 'Catalog admin signed in' : 'Browsing as guest',
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
                        isAdmin ? AdminConfig.seedEmail : 'Guest',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MonVlogTheme.onBg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAdmin ? 'Admin' : 'Watch-only access',
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
            'Account',
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
            label: isAdmin ? 'Open catalog admin' : 'Admin sign-in',
            onTap: () => context.go(
              isAdmin ? '/admin/catalog' : '/admin/login',
            ),
          ),
          if (isAdmin)
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: 'Sign out to guest',
              onTap: () async {
                await ref.read(adminSessionProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signed out — browsing as guest'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          const SizedBox(height: 20),
          Text(
            'App',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MonVlogTheme.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.info_outline_rounded,
            label: 'About MonVlog',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MonVlog',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Монголчуудын нэгдэл',
              );
            },
          ),
        ],
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
