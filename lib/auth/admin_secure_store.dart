import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin key/value store used by [AdminAuthService] (password hash + biometric flag).
abstract class AdminSecureStore {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});
}

class FlutterAdminSecureStore implements AdminSecureStore {
  FlutterAdminSecureStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);
}

/// In-memory store for unit tests (no platform channels).
class MemoryAdminSecureStore implements AdminSecureStore {
  final Map<String, String> map = {};

  @override
  Future<String?> read({required String key}) async => map[key];

  @override
  Future<void> write({required String key, required String value}) async {
    map[key] = value;
  }
}
