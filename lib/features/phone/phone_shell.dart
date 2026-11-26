import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import '../../l10n/app_localizations.dart';
import 'community_screen.dart';
import 'phone_profile_screen.dart';
import 'phone_watch_screen.dart';

/// Phone shell: Community + Watch + Profile with a persistent bottom menu.
///
/// Bottom nav is phone-only — TV uses [TvShell] left rail instead.
/// Nested page scaffolds are avoided so the bar cannot be clipped or
/// painted dark-on-dark under an inner [Scaffold].
class PhoneShell extends ConsumerStatefulWidget {
  const PhoneShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  static const tabPaths = ['/phone', '/phone/watch', '/phone/profile'];

  @override
  ConsumerState<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends ConsumerState<PhoneShell> {
  late int _index;

  static const _pages = [
    CommunityScreen(),
    PhoneWatchScreen(),
    PhoneProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  @override
  void didUpdateWidget(covariant PhoneShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex.clamp(0, _pages.length - 1);
    }
  }

  void _selectTab(int i) {
    if (i == _index) return;
    final path = PhoneShell.tabPaths[i];
    final current = GoRouterState.of(context).uri.path;
    if (current != path) {
      // Route swap rebuilds PhoneShell with the matching initialIndex.
      context.go(path);
      return;
    }
    setState(() => _index = i);
  }

  void _openAdmin() {
    final isAdmin = ref.read(isAdminProvider);
    context.go(isAdmin ? '/admin/catalog' : '/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    final labelStyle = GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: MonVlogTheme.onBg,
    );

    return Scaffold(
      backgroundColor: MonVlogTheme.communityBg,
      // Keep the bottom menu above system gesture insets and always painted.
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: _pages,
          ),
          if (_index != 2)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 4,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  tooltip: isAdmin ? l10n.catalogAdmin : l10n.adminSignIn,
                  onPressed: _openAdmin,
                  icon: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.manage_accounts_outlined,
                    color: MonVlogTheme.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Material(
        color: MonVlogTheme.communityBg,
        elevation: 8,
        shadowColor: Colors.black54,
        child: SafeArea(
          top: false,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x33FFFFFF), width: 1),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _selectTab,
              height: 68,
              backgroundColor: MonVlogTheme.communityBg,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              indicatorColor: MonVlogTheme.coral.withValues(alpha: 0.22),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return labelStyle.copyWith(
                  color: selected ? MonVlogTheme.coral : MonVlogTheme.onBg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                );
              }),
              destinations: [
                NavigationDestination(
                  icon: const Icon(
                    Icons.home_outlined,
                    color: MonVlogTheme.onBg,
                  ),
                  selectedIcon: const Icon(
                    Icons.home_rounded,
                    color: MonVlogTheme.coral,
                  ),
                  label: l10n.navCommunity,
                ),
                NavigationDestination(
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: MonVlogTheme.onBg,
                  ),
                  selectedIcon: const Icon(
                    Icons.play_circle_filled_rounded,
                    color: MonVlogTheme.brandRed,
                  ),
                  label: l10n.navWatch,
                ),
                NavigationDestination(
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: MonVlogTheme.onBg,
                  ),
                  selectedIcon: const Icon(
                    Icons.person_rounded,
                    color: MonVlogTheme.coral,
                  ),
                  label: l10n.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
