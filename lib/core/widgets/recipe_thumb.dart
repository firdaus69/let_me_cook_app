import 'package:flutter/material.dart';

import '../../data/models/recipe.dart';
import '../theme/app_colors.dart';

/// Tinted placeholder shown where a recipe photo will go.
class RecipeThumb extends StatelessWidget {
  const RecipeThumb({
    super.key,
    required this.recipe,
    required this.size,
    this.radius = 14,
    this.showPhotoLabel = false,
  });

  final Recipe recipe;
  final Size size;
  final double radius;
  final bool showPhotoLabel;

  @override
  Widget build(BuildContext context) {
    final tone = AppColors.tone(recipe.tone);
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: tone.tint,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.ramen_dining_outlined,
            size: size.shortestSide * 0.4,
            color: tone.ink,
          ),
          if (showPhotoLabel)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Photo',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
