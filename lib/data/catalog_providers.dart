import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_repository.dart';
import 'catalog_store.dart';
import 'curated_channels_loader.dart';
import 'models/curated_channel.dart';
import 'shelf_categorizer.dart';
import 'youtube/youtube_api_client.dart';
import 'youtube/youtube_search_models.dart';

final curatedChannelsLoaderProvider = Provider<CuratedChannelsLoader>((ref) {
  return CuratedChannelsLoader();
});

final catalogStoreProvider = Provider<CatalogStore>((ref) {
  return CatalogStore(loader: ref.watch(curatedChannelsLoaderProvider));
});

final shelfCategorizerProvider = Provider<ShelfCategorizer>((ref) {
  return const ShelfCategorizer();
});

/// Merged curated catalog (asset/remote + local admin overrides).
final curatedCatalogProvider = FutureProvider<CuratedCatalogConfig>((ref) {
  return ref.watch(catalogStoreProvider).loadMerged();
});

final localPlaylistsProvider = FutureProvider<List<CuratedPlaylist>>((ref) {
  return ref.watch(catalogStoreProvider).loadLocalPlaylists();
});

final youtubeApiClientProvider = Provider<YoutubeApiClient>((ref) {
  return YoutubeApiClient();
});

final catalogRepositoryProvider = FutureProvider<CatalogRepository>((ref) async {
  final curated = await ref.watch(curatedCatalogProvider.future);
  return CatalogRepository(
    api: ref.watch(youtubeApiClientProvider),
    curated: curated,
    categorizer: ref.watch(shelfCategorizerProvider),
  );
});

final homeCatalogProvider = FutureProvider<CatalogSnapshot>((ref) async {
  final repo = await ref.watch(catalogRepositoryProvider.future);
  return repo.loadHomeShelves();
});

/// Admin channel/playlist search (live or mock when key missing).
final channelSearchQueryProvider = StateProvider<String>((ref) => '');

final channelSearchProvider =
    FutureProvider.autoDispose<YoutubeChannelSearchResult>((ref) async {
  final query = ref.watch(channelSearchQueryProvider).trim();
  if (query.isEmpty) {
    return const YoutubeChannelSearchResult(
      hits: [],
      isMock: false,
      message: '',
    );
  }
  final api = ref.watch(youtubeApiClientProvider);
  return api.searchChannelsByName(query);
});
