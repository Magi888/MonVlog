import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monvlog/data/curated_channels_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('in-repo curated_channels.json loads and marks stubs', () async {
    final raw =
        await rootBundle.loadString('assets/config/curated_channels.json');
    final config = CuratedChannelsLoader.parseJsonString(raw);

    expect(config.channels.length, greaterThanOrEqualTo(15));
    expect(config.channels.length, lessThanOrEqualTo(30));
    expect(config.apiReady, isNotEmpty);
    expect(config.apiReady.every((c) => c.channelId.startsWith('UC')), isTrue);
    expect(config.channels.any((c) => c.isStub), isTrue);

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    expect(decoded['version'], 1);
  });
}
