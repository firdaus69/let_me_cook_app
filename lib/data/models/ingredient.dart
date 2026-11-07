enum IngredientCategory {
  protein('Protein'),
  vegetables('Vegetables'),
  dairy('Dairy'),
  pantry('Pantry'),
  spices('Spices');

  const IngredientCategory(this.label);
  final String label;
}

class Ingredient {
  const Ingredient(this.name, this.category);

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    json['name'] as String,
    IngredientCategory.values.byName(json['category'] as String),
  );

  final String name;
  final IngredientCategory category;
}
