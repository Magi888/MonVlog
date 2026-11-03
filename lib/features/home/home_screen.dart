import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/catalog_providers.dart';
import '../../data/catalog_repository.dart';
import 'widgets/shelf_row.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(homeCatalogProvider);

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
                if (!_scrollController.hasClients) return null;
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
          child: catalog.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: MonVlogTheme.accent),
            ),
            error: (err, _) => Center(
              child: Text(
                'Catalog error: $err',
                style: const TextStyle(color: MonVlogTheme.onBg),
              ),
            ),
            data: (snapshot) => _HomeBody(
              snapshot: snapshot,
              scrollController: _scrollController,
              onRetry: () => ref.invalidate(homeCatalogProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.snapshot,
    required this.scrollController,
    required this.onRetry,
  });

  final CatalogSnapshot snapshot;
  final ScrollController scrollController;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final shelves = snapshot.shelves;
    final sourceLabel = snapshot.isMock ? 'Mock fallback' : 'Live YouTube';
    final stubCount = snapshot.channels.where((c) => c.isStub).length;

    return CustomScrollView(
      controller: scrollController,
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
                  child: Text(
                    sourceLabel,
                    style: const TextStyle(
                      color: MonVlogTheme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${snapshot.channels.length} curated'
                  '${stubCount > 0 ? ' · $stubCount stubs' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MonVlogTheme.muted,
                      ),
                ),
                if (snapshot.isMock)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
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
    );
  }
}
