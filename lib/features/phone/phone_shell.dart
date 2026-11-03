import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'community_screen.dart';
import 'phone_watch_screen.dart';

/// Phone mockup shell: Community (reference look) + Watch shelves.
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
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
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
