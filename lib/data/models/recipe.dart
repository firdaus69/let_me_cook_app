enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.label);
  final String label;
}

/// Colour family used for a recipe's placeholder thumbnail until real photos exist.
enum RecipeTone { orange, green, yellow, red, brown }

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.minutes,
    required this.difficulty,
    required this.ingredients,
    this.tone = RecipeTone.orange,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    title: json['title'] as String,
    minutes: json['minutes'] as int,
    difficulty: Difficulty.values.byName(json['difficulty'] as String),
    ingredients: (json['ingredients'] as List).cast<String>(),
    tone: RecipeTone.values.asNameMap()[json['tone']] ?? RecipeTone.orange,
  );

  final String id;
  final String title;
  final int minutes;
  final Difficulty difficulty;

  /// Ingredient names; must match [Ingredient.name] in the catalogue.
  final List<String> ingredients;
  final RecipeTone tone;

  String get durationLabel {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60, m = minutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  String get subtitle => '$durationLabel · ${difficulty.label}';
}
