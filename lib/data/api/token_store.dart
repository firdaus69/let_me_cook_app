import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the login token in the platform keychain / keystore so the user
/// stays logged in between app launches.
class TokenStore {
  const TokenStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;
  static const _key = 'auth_token';

  Future<String?> read() => _storage.read(key: _key);
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  Future<void> delete() => _storage.delete(key: _key);
}

final tokenStoreProvider = Provider<TokenStore>((ref) => const TokenStore());
