import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/fridge/recipe_match.dart';
import 'api/api_client.dart';
import 'models/country.dart';
import 'models/ingredient.dart';
import 'models/recipe.dart';

/// Recipe data from the Let Me Cook API.
class RecipeRepository {
  const RecipeRepository(this._api);

  final ApiClient _api;

  Future<List<Country>> countries() async =>
      _list(await _api.get('/countries'), Country.fromJson);

  Future<List<Ingredient>> ingredients() async =>
      _list(await _api.get('/ingredients'), Ingredient.fromJson);

  Future<List<Recipe>> suggestedFor(Country country) async => _list(
    await _api.get('/recipes/suggested?country=${country.code}&limit=5'),
    Recipe.fromJson,
  );

  Future<List<Recipe>> popularIn(Country country) async => _list(
    await _api.get('/recipes/popular?country=${country.code}&limit=5'),
    Recipe.fromJson,
  );

  /// Recipes the [ingredients] can make: ready ones first, then those missing
  /// 1–2 ingredients. The matching rules live on the server.
  Future<List<RecipeMatch>> match(Iterable<String> ingredients) async {
    final data =
        await _api.post(
              '/recipes/match',
              body: {'ingredients': ingredients.toList()},
            )
            as Map<String, dynamic>;
    return [
      ..._list(data['ready'], RecipeMatch.fromJson),
      ..._list(data['almost'], RecipeMatch.fromJson),
    ];
  }

  Future<List<Recipe>> saved(String token) async =>
      _list(await _api.get('/me/saved', token: token), Recipe.fromJson);

  Future<void> save(String recipeId, String token) =>
      _api.put('/me/saved/$recipeId', token: token);

  Future<void> unsave(String recipeId, String token) =>
      _api.delete('/me/saved/$recipeId', token: token);

  static List<T> _list<T>(
    Object? json,
    T Function(Map<String, dynamic>) fromJson,
  ) => (json as List).cast<Map<String, dynamic>>().map(fromJson).toList();
}

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepository(ref.watch(apiClientProvider)),
);

class CountryController extends Notifier<Country> {
  @override
  Country build() => const Country('MY', 'Malaysia');

  void select(Country country) => state = country;
}

final countryProvider = NotifierProvider<CountryController, Country>(
  CountryController.new,
);

final countriesProvider = FutureProvider<List<Country>>(
  (ref) => ref.watch(recipeRepositoryProvider).countries(),
);

final ingredientsProvider = FutureProvider<List<Ingredient>>(
  (ref) => ref.watch(recipeRepositoryProvider).ingredients(),
);

final suggestedRecipesProvider = FutureProvider<List<Recipe>>(
  (ref) => ref
      .watch(recipeRepositoryProvider)
      .suggestedFor(ref.watch(countryProvider)),
);

final popularRecipesProvider = FutureProvider<List<Recipe>>(
  (ref) =>
      ref.watch(recipeRepositoryProvider).popularIn(ref.watch(countryProvider)),
);
