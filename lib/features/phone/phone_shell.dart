import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../auth/admin_auth_providers.dart';
import 'community_screen.dart';
import 'phone_watch_screen.dart';

/// Phone shell: Community (Wix-like) + Netflix Watch rails.
/// Bottom nav is phone-only — TV uses [TvShell] left rail instead.
/// Viewers browse only; admin reaches catalog via the overflow menu.
class PhoneShell extends ConsumerStatefulWidget {
  const PhoneShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends ConsumerState<PhoneShell> {
  late int _index;

  static const _pages = [
    CommunityScreen(),
    PhoneWatchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  void _openAdmin() {
    final isAdmin = ref.read(isAdminProvider);
    context.go(isAdmin ? '/admin/catalog' : '/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: MonVlogTheme.communityBg,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: _pages,
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                tooltip: isAdmin ? 'Catalog admin' : 'Admin sign-in',
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 68,
        backgroundColor: MonVlogTheme.communityBg,
        indicatorColor: MonVlogTheme.coral.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: MonVlogTheme.coral),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(
              Icons.play_circle_filled_rounded,
              color: MonVlogTheme.brandRed,
            ),
            label: 'Watch',
          ),
        ],
      ),
    );
  }
}
