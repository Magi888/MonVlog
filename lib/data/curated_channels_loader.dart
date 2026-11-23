import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'models/curated_channel.dart';
import 'youtube/youtube_config.dart';

/// Loads the curated allowlist from in-repo asset or optional remote URL.
class CuratedChannelsLoader {
  CuratedChannelsLoader({
    Dio? dio,
    AssetBundle? bundle,
    this.assetPath = 'assets/config/curated_channels.json',
  })  : _dio = dio ?? Dio(),
        _bundle = bundle ?? rootBundle;

  final Dio _dio;
  final AssetBundle _bundle;
  final String assetPath;

  Future<CuratedCatalogConfig> load({
    String? remoteUrl,
  }) async {
    final url = (remoteUrl ?? YoutubeConfig.curatedChannelsUrl).trim();
    if (url.isNotEmpty) {
      try {
        final response = await _dio.get<dynamic>(url);
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return CuratedCatalogConfig.fromJson(data);
        }
        if (data is Map) {
          return CuratedCatalogConfig.fromJson(Map<String, dynamic>.from(data));
        }
        if (data is String) {
          return CuratedCatalogConfig.fromJson(
            jsonDecode(data) as Map<String, dynamic>,
          );
        }
      } catch (_) {
        // Fall through to in-repo asset.
      }
    }
    return loadFromAsset();
  }

  Future<CuratedCatalogConfig> loadFromAsset() async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('curated_channels.json root must be an object');
    }
    return CuratedCatalogConfig.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Sync parse helper for unit tests (no asset / network).
  static CuratedCatalogConfig parseJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('curated channels root must be an object');
    }
    return CuratedCatalogConfig.fromJson(Map<String, dynamic>.from(decoded));
  }
}
