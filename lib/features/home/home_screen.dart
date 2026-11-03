import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/mock_catalog.dart';
import 'widgets/shelf_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shelves = MockCatalog.shelves;

    return Scaffold(
      body: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowDown):
              ScrollIntent(direction: AxisDirection.down),
          SingleActivator(LogicalKeyboardKey.arrowUp):
              ScrollIntent(direction: AxisDirection.up),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ScrollIntent: CallbackAction<ScrollIntent>(
              onInvoke: (intent) {
                final delta =
                    intent.direction == AxisDirection.down ? 220.0 : -220.0;
                _scrollController.animateTo(
                  (_scrollController.offset + delta).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                );
                return null;
              },
            ),
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 40, 48, 16),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'MonVlog',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: MonVlogTheme.onBg,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: MonVlogTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'MVP shell',
                          style: TextStyle(
                            color: MonVlogTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Mock catalog · billing stubbed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: MonVlogTheme.muted,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shelf = shelves[index];
                    return ShelfRow(
                      shelf: shelf,
                      autofocusFirst: index == 0,
                    );
                  },
                  childCount: shelves.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
        ),
      ),
    );
  }
}
