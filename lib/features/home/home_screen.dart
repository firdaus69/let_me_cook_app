import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/recipe_row.dart';
import '../../data/recipe_repository.dart';
import '../auth/auth_controller.dart';
import 'widgets/country_picker.dart';
import 'widgets/fridge_hero_card.dart';
import 'widgets/section_header.dart';
import 'widgets/suggested_recipe_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(countryProvider);
    final suggested = ref.watch(suggestedRecipesProvider);
    final popular = ref.watch(popularRecipesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => Future.wait([
            ref.refresh(suggestedRecipesProvider.future),
            ref.refresh(popularRecipesProvider.future),
          ]),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const _Header(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: FridgeHeroCard(),
              ),
              const SizedBox(height: 28),

              // 1. Recipe suggestion — 5 recipes for the user's country.
              SectionHeader(
                title: 'Suggested for you',
                subtitle: suggested.hasValue
                    ? '${suggested.requireValue.length} picks based on ${country.name}'
                    : 'Picks based on ${country.name}',
                onSeeAll: () {},
              ),
              const SizedBox(height: 14),
              AsyncView(
                value: suggested,
                height: 232,
                onRetry: () => ref.invalidate(suggestedRecipesProvider),
                data: (recipes) => SizedBox(
                  height: 232,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: recipes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        SuggestedRecipeCard(recipe: recipes[i]),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 3. Popular — top 5 in the user's country.
              SectionHeader(
                title: 'Popular in ${country.name}',
                subtitle: popular.hasValue
                    ? 'Top ${popular.requireValue.length} most-cooked recipes'
                    : 'Most-cooked recipes',
                onSeeAll: () {},
              ),
              const SizedBox(height: 14),
              AsyncView(
                value: popular,
                height: 200,
                onRetry: () => ref.invalidate(popularRecipesProvider),
                data: (recipes) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (var i = 0; i < recipes.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        RecipeRow(recipe: recipes[i], rank: i + 1),
                      ],
                    ],
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

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final greeting = auth.isLoggedIn
        ? 'Hi, ${auth.email!.split('@').first}'
        : 'Good ${_partOfDay()}, chef';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CountryPickerButton(),
              const Spacer(),
              _CircleButton(
                tooltip: 'Notifications',
                onPressed: () {},
                child: const Icon(
                  Icons.notifications_none,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 8),
              _CircleButton(
                tooltip: 'Profile',
                filled: true,
                onPressed: () => context.go(AppRoutes.profile),
                child: auth.isLoggedIn
                    ? Text(
                        auth.email![0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentDark,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: AppColors.accentDark,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What are we cooking today?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 16),
          const TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search recipes or ingredients',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }

  static String _partOfDay() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 18) return 'afternoon';
    return 'evening';
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
    this.filled = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? const Color(0xFFFFE4D6) : AppColors.surface,
        shape: CircleBorder(
          side: filled
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(dimension: 44, child: Center(child: child)),
        ),
      ),
    );
  }
}
