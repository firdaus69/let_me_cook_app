import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/ingredient.dart';
import '../../data/recipe_repository.dart';
import 'recipe_match.dart';

class FridgeState {
  const FridgeState({this.selected = const {}, this.category, this.query = ''});

  final Set<String> selected;

  /// `null` means "All".
  final IngredientCategory? category;
  final String query;

  FridgeState copyWith({
    Set<String>? selected,
    IngredientCategory? Function()? category,
    String? query,
  }) => FridgeState(
    selected: selected ?? this.selected,
    category: category != null ? category() : this.category,
    query: query ?? this.query,
  );
}

class FridgeController extends Notifier<FridgeState> {
  @override
  FridgeState build() => const FridgeState();

  void toggle(String ingredient) {
    final next = {...state.selected};
    if (!next.remove(ingredient)) next.add(ingredient);
    state = state.copyWith(selected: next);
  }

  void clear() => state = state.copyWith(selected: {});

  void setCategory(IngredientCategory? category) =>
      state = state.copyWith(category: () => category);

  void setQuery(String query) => state = state.copyWith(query: query);
}

final fridgeControllerProvider =
    NotifierProvider<FridgeController, FridgeState>(FridgeController.new);

/// Ingredients shown in the picker after category and search filters.
final visibleIngredientsProvider = Provider<AsyncValue<List<Ingredient>>>((
  ref,
) {
  final fridge = ref.watch(fridgeControllerProvider);
  final query = fridge.query.trim().toLowerCase();
  return ref
      .watch(ingredientsProvider)
      .whenData(
        (all) => all.where((i) {
          if (fridge.category != null && i.category != fridge.category) {
            return false;
          }
          return query.isEmpty || i.name.toLowerCase().contains(query);
        }).toList(),
      );
});

/// Asks the server which recipes the selected ingredients can make.
final fridgeMatchesProvider = FutureProvider.autoDispose<List<RecipeMatch>>((
  ref,
) {
  final selected = ref.watch(fridgeControllerProvider).selected;
  if (selected.isEmpty) return const [];
  return ref.watch(recipeRepositoryProvider).match(selected);
});
