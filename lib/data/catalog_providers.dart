import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_repository.dart';
import 'curated_channels_loader.dart';
import 'models/curated_channel.dart';
import 'youtube/youtube_api_client.dart';

final curatedChannelsLoaderProvider = Provider<CuratedChannelsLoader>((ref) {
  return CuratedChannelsLoader();
});

final curatedCatalogProvider = FutureProvider<CuratedCatalogConfig>((ref) {
  return ref.watch(curatedChannelsLoaderProvider).load();
});

final youtubeApiClientProvider = Provider<YoutubeApiClient>((ref) {
  return YoutubeApiClient();
});

final catalogRepositoryProvider = FutureProvider<CatalogRepository>((ref) async {
  final curated = await ref.watch(curatedCatalogProvider.future);
  return CatalogRepository(
    api: ref.watch(youtubeApiClientProvider),
    curated: curated,
  );
});

final homeCatalogProvider = FutureProvider<CatalogSnapshot>((ref) async {
  final repo = await ref.watch(catalogRepositoryProvider.future);
  return repo.loadHomeShelves();
});
