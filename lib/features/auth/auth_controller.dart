import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import '../../data/api/token_store.dart';

class AuthState {
  const AuthState({this.email, this.token, this.isLoading = false, this.error});

  final String? email;
  final String? token;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => token != null;
}

/// Logs in against the API and remembers the token between launches.
class AuthController extends Notifier<AuthState> {
  ApiClient get _api => ref.read(apiClientProvider);
  TokenStore get _tokens => ref.read(tokenStoreProvider);

  @override
  AuthState build() {
    _restoreSession();
    return const AuthState();
  }

  Future<bool> login(String email, String password) =>
      _authenticate('/auth/login', email, password);

  Future<bool> register(String email, String password) =>
      _authenticate('/auth/register', email, password);

  Future<void> logout() async {
    state = const AuthState();
    await _tokens.delete();
  }

  Future<bool> _authenticate(String path, String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final data =
          await _api.post(path, body: {'email': email, 'password': password})
              as Map<String, dynamic>;
      final token = data['token'] as String;
      await _tokens.write(token);
      state = AuthState(email: _emailOf(data['user']), token: token);
      return true;
    } on ApiException catch (e) {
      state = AuthState(error: e.message);
      return false;
    }
  }

  /// Picks up a token saved by an earlier launch, if it's still valid.
  Future<void> _restoreSession() async {
    final token = await _tokens.read();
    if (token == null) return;
    try {
      final user = await _api.get('/me', token: token);
      if (!state.isLoggedIn) {
        state = AuthState(email: _emailOf(user), token: token);
      }
    } on ApiException catch (e) {
      // Expired or revoked. (If the server is just unreachable, keep the token
      // and try again next launch.)
      if (e.statusCode == 401) await _tokens.delete();
    }
  }

  static String _emailOf(Object? user) =>
      (user as Map<String, dynamic>)['email'] as String;
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
