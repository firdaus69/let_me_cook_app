import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_view.dart';
import '../../data/models/ingredient.dart';
import '../../data/recipe_repository.dart';
import 'fridge_controller.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridge = ref.watch(fridgeControllerProvider);
    final controller = ref.read(fridgeControllerProvider.notifier);
    final ingredients = ref.watch(visibleIngredientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My fridge'),
        actions: [
          TextButton(
            onPressed: fridge.selected.isEmpty ? null : controller.clear,
            child: const Text('Clear'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What's in your fridge?",
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap everything you have. The more you pick, the better the match.',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: controller.setQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search ingredients',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              children: [
                _CategoryTab(
                  label: 'All',
                  active: fridge.category == null,
                  onTap: () => controller.setCategory(null),
                ),
                for (final c in IngredientCategory.values)
                  _CategoryTab(
                    label: c.label,
                    active: fridge.category == c,
                    onTap: () => controller.setCategory(c),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView(
              value: ingredients,
              onRetry: () => ref.invalidate(ingredientsProvider),
              data: (ingredients) => ingredients.isEmpty
                  ? const Center(
                      child: Text(
                        'No ingredients match your search.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 84,
                          ),
                      itemCount: ingredients.length,
                      itemBuilder: (context, i) {
                        final ingredient = ingredients[i];
                        return _IngredientTile(
                          ingredient: ingredient,
                          selected: fridge.selected.contains(ingredient.name),
                          onTap: () => controller.toggle(ingredient.name),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _SelectionTray(selected: fridge.selected),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: active ? AppColors.ink : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(color: active ? AppColors.ink : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    required this.selected,
    required this.onTap,
  });

  final Ingredient ingredient;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.accentTint : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.category(ingredient.category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ingredient.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTray extends StatelessWidget {
  const _SelectionTray({required this.selected});

  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final count = selected.length;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1F1A17),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '$count ${count == 1 ? 'ingredient' : 'ingredients'} selected',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selected.join(', '),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: count == 0
                    ? null
                    : () => context.push(AppRoutes.fridgeResults),
                icon: const Icon(Icons.room_service_outlined),
                label: Text(
                  count == 0 ? 'Pick at least 1 ingredient' : 'Find recipes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
