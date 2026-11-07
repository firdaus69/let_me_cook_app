import 'dart:convert';

import 'package:flutter_riverpod/misc.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:let_me_cook/data/api/api_client.dart';
import 'package:let_me_cook/data/api/token_store.dart';
import 'package:let_me_cook/data/models/recipe.dart';

import 'sample_data.dart';

/// An in-memory stand-in for the Let Me Cook API, serving [sampleRecipes].
/// Accepts any password of 8+ characters.
class FakeApi {
  /// Pass [offline] to make every request fail as if the server were down.
  FakeApi({bool offline = false}) : _offline = offline;

  final bool _offline;
  final users = <String, String>{}; // token -> email
  final saved = <String, List<String>>{}; // email -> recipe ids, newest first

  late final client = MockClient(
    (req) => _offline
        ? throw http.ClientException('Connection refused')
        : _handle(req),
  );

  /// Provider overrides that point the app at this fake.
  List<Override> get overrides => [
    httpClientProvider.overrideWithValue(client),
    tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
  ];

  Future<http.Response> _handle(http.Request req) async {
    final path = req.url.path;
    final email =
        users[req.headers['authorization']?.replaceFirst('Bearer ', '')];
    final body = req.body.isEmpty ? null : jsonDecode(req.body) as Map;

    switch ((req.method, path)) {
      case ('GET', '/countries'):
        return _json([
          for (final c in supportedCountries) {'code': c.code, 'name': c.name},
        ]);
      case ('GET', '/ingredients'):
        return _json([
          for (final i in sampleIngredients)
            {'name': i.name, 'category': i.category.name},
        ]);
      case ('GET', '/recipes/suggested'):
        return _json(
          _recipes(sampleSuggested[req.url.queryParameters['country']]),
        );
      case ('GET', '/recipes/popular'):
        return _json(
          _recipes(samplePopular[req.url.queryParameters['country']]),
        );
      case ('POST', '/recipes/match'):
        final owned = (body!['ingredients'] as List).cast<String>().toSet();
        final matches =
            [
              for (final r in sampleRecipes)
                (r, r.ingredients.where((i) => !owned.contains(i)).toList()),
            ].where(
              (m) => m.$2.length <= 2 && m.$2.length < m.$1.ingredients.length,
            );
        Map<String, Object> dto((Recipe, List<String>) m) => {
          'recipe': _recipe(m.$1),
          'missing': m.$2,
        };
        return _json({
          'ready': matches.where((m) => m.$2.isEmpty).map(dto).toList(),
          'almost': matches.where((m) => m.$2.isNotEmpty).map(dto).toList(),
          'unknownIngredients': <String>[],
        });
      case ('POST', '/auth/register' || '/auth/login'):
        if ((body!['password'] as String).length < 8) {
          return _json({'error': 'Invalid email or password'}, 401);
        }
        final token = 'token-${users.length}';
        users[token] = body['email'] as String;
        return _json({
          'token': token,
          'user': {'id': token, 'email': body['email'], 'countryCode': 'MY'},
        });
    }

    if (email == null) return _json({'error': 'Unauthorized'}, 401);
    final mine = saved.putIfAbsent(email, () => []);
    final savedId = RegExp(r'^/me/saved/(.+)$').firstMatch(path)?.group(1);
    switch (req.method) {
      case 'GET' when path == '/me':
        return _json({'id': '1', 'email': email, 'countryCode': 'MY'});
      case 'GET' when path == '/me/saved':
        return _json(_recipes(mine));
      case 'PUT' when savedId != null:
        mine
          ..remove(savedId)
          ..insert(0, savedId);
        return http.Response('', 204);
      case 'DELETE' when savedId != null:
        mine.remove(savedId);
        return http.Response('', 204);
    }
    return _json({'error': 'Not found'}, 404);
  }

  static List<Map<String, Object>> _recipes(List<String>? ids) => [
    for (final id in ids ?? const <String>[])
      _recipe(sampleRecipes.firstWhere((r) => r.id == id)),
  ];

  static Map<String, Object> _recipe(Recipe r) => {
    'id': r.id,
    'title': r.title,
    'minutes': r.minutes,
    'difficulty': r.difficulty.name,
    'tone': r.tone.name,
    'countryCode': 'MY',
    'ingredients': r.ingredients,
  };

  static http.Response _json(Object data, [int status = 200]) => http.Response(
    jsonEncode(data),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

class MemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;
  @override
  Future<void> write(String token) async => _token = token;
  @override
  Future<void> delete() async => _token = null;
}
