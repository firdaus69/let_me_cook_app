import 'package:flutter/material.dart';

import '../../data/models/ingredient.dart';
import '../../data/models/recipe.dart';

class AppColors {
  AppColors._();

  static const ink = Color(0xFF1F1A17);
  static const muted = Color(0xFF6B625C);
  static const background = Color(0xFFFCFAF7);
  static const surface = Colors.white;
  static const border = Color(0xFFEAE3DC);
  static const borderSoft = Color(0xFFEFE9E3);
  static const segment = Color(0xFFF2EDE8);

  static const accent = Color(0xFFC2410C);
  static const accentDark = Color(0xFF9A3412);
  static const accentTint = Color(0xFFFFF1EA);
  static const accentTrack = Color(0xFFFBE3D7);

  static const success = Color(0xFF15803D);
  static const successTint = Color(0xFFE3F1E4);

  static ({Color tint, Color ink}) tone(RecipeTone tone) => switch (tone) {
    RecipeTone.orange => (tint: const Color(0xFFFFE8DC), ink: accentDark),
    RecipeTone.green => (
      tint: const Color(0xFFE3F1E4),
      ink: const Color(0xFF2F6B35),
    ),
    RecipeTone.yellow => (
      tint: const Color(0xFFFDF0C9),
      ink: const Color(0xFF8A5A00),
    ),
    RecipeTone.red => (
      tint: const Color(0xFFFBE0DE),
      ink: const Color(0xFFA1281F),
    ),
    RecipeTone.brown => (
      tint: const Color(0xFFF1E6DC),
      ink: const Color(0xFF6E4A2E),
    ),
  };

  static Color category(IngredientCategory c) => switch (c) {
    IngredientCategory.protein => const Color(0xFFF6C9B8),
    IngredientCategory.vegetables => const Color(0xFFCFE6C6),
    IngredientCategory.dairy => const Color(0xFFE6E0F5),
    IngredientCategory.pantry => const Color(0xFFF5E3B5),
    IngredientCategory.spices => const Color(0xFFF3D0C2),
  };
}
