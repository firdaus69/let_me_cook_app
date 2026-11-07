import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import '../../data/models/recipe.dart';
import '../../data/recipe_repository.dart';
import '../auth/auth_controller.dart';

/// Recipes the user bookmarked, newest first.
///
/// Logged out, they live in memory. Logged in, they are stored on the server,
/// and anything saved before logging in is uploaded at login.
class SavedController extends Notifier<Map<String, Recipe>> {
  RecipeRepository get _repo => ref.read(recipeRepositoryProvider);
  String? get _token => ref.read(authControllerProvider).token;

  @override
  Map<String, Recipe> build() {
    ref.listen(authControllerProvider.select((a) => a.token), (_, token) {
      if (token != null) {
        _syncAfterLogin(token);
      } else {
        state = const {};
      }
    });
    final token = _token;
    if (token != null) Future.microtask(() => _syncAfterLogin(token));
    return const {};
  }

  /// Saves or un-saves [recipe]. Returns false if the server rejected it,
  /// in which case the change is rolled back.
  Future<bool> toggle(Recipe recipe) async {
    final before = state;
    final saving = !before.containsKey(recipe.id);
    state = saving
        ? {recipe.id: recipe, ...before}
        : ({...before}..remove(recipe.id));

    final token = _token;
    if (token == null) return true;
    try {
      saving
          ? await _repo.save(recipe.id, token)
          : await _repo.unsave(recipe.id, token);
      return true;
    } on ApiException {
      state = before;
      return false;
    }
  }

  Future<void> _syncAfterLogin(String token) async {
    final local = state.keys.toList();
    try {
      for (final id in local.reversed) {
        await _repo.save(id, token);
      }
      final remote = await _repo.saved(token);
      state = {for (final r in remote) r.id: r};
    } on ApiException {
      // Keep what's on the device; it syncs again at the next login.
    }
  }
}

final savedRecipesProvider =
    NotifierProvider<SavedController, Map<String, Recipe>>(SavedController.new);
