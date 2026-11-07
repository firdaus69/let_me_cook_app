// Checks the app's API code against a real, running backend.
// Skipped unless you pass the server's address:
//   flutter test test/live_api_test.dart --dart-define=API_URL=http://localhost:3000
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:let_me_cook/data/api/api_client.dart';
import 'package:let_me_cook/data/models/country.dart';
import 'package:let_me_cook/data/recipe_repository.dart';

const _apiUrl = String.fromEnvironment('API_URL');

void main() {
  final repo = RecipeRepository(ApiClient(http.Client(), baseUrl: _apiUrl));
  const malaysia = Country('MY', 'Malaysia');

  group('Live API', skip: _apiUrl.isEmpty ? 'Set API_URL to run' : null, () {
    test('loads the catalogue and home lists', () async {
      expect((await repo.countries()).map((c) => c.code), contains('MY'));
      expect(await repo.ingredients(), hasLength(greaterThan(20)));
      expect((await repo.suggestedFor(malaysia)).first.id, 'nasi-lemak');
      expect(await repo.popularIn(malaysia), hasLength(5));
    });

    test('matches fridge ingredients', () async {
      final matches = await repo.match(['Eggs', 'Onion', 'Chili']);
      final ready = matches.where((m) => m.isReady).map((m) => m.recipe.id);
      expect(ready, contains('telur-dadar-bawang'));
      expect(matches.any((m) => !m.isReady), isTrue);
    });

    test('reports server errors with a readable message', () async {
      final api = ApiClient(http.Client(), baseUrl: _apiUrl);
      await expectLater(
        api.post(
          '/auth/login',
          body: {'email': 'nobody@example.com', 'password': 'wrong-pass'},
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 401)
              .having((e) => e.message, 'message', 'Invalid email or password'),
        ),
      );
    });
  });
}
