import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import 'community_screen.dart';
import 'phone_watch_screen.dart';

/// Phone shell: Community (Wix-like) + Netflix Watch rails.
/// Bottom nav is phone-only — TV uses [TvShell] left rail instead.
class PhoneShell extends StatefulWidget {
  const PhoneShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<PhoneShell> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonVlogTheme.communityBg,
      body: IndexedStack(
        index: _index,
        children: _pages,
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
