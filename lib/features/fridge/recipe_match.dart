import '../../data/models/recipe.dart';

/// A recipe the user's fridge can make, and what they'd still need to buy.
class RecipeMatch {
  const RecipeMatch(this.recipe, this.missing);

  factory RecipeMatch.fromJson(Map<String, dynamic> json) => RecipeMatch(
    Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
    (json['missing'] as List).cast<String>(),
  );

  final Recipe recipe;
  final List<String> missing;

  int get need => recipe.ingredients.length;
  int get have => need - missing.length;
  double get ratio => need == 0 ? 0 : have / need;
  bool get isReady => missing.isEmpty;
}
