import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/recipe_thumb.dart';
import 'fridge_controller.dart';
import 'recipe_match.dart';

enum _Sort { bestMatch, quickest }

class FridgeResultsScreen extends ConsumerStatefulWidget {
  const FridgeResultsScreen({super.key});

  @override
  ConsumerState<FridgeResultsScreen> createState() =>
      _FridgeResultsScreenState();
}

class _FridgeResultsScreenState extends ConsumerState<FridgeResultsScreen> {
  _Sort _sort = _Sort.bestMatch;

  List<RecipeMatch> _sorted(Iterable<RecipeMatch> matches) {
    final list = matches.toList();
    if (_sort == _Sort.quickest) {
      list.sort((a, b) => a.recipe.minutes.compareTo(b.recipe.minutes));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(fridgeControllerProvider).selected;
    final matches = ref.watch(fridgeMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes you can make'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _IngredientsSummary(selected: selected),
          const SizedBox(height: 18),
          _SortToggle(
            value: _sort,
            onChanged: (s) => setState(() => _sort = s),
          ),
          AsyncView(
            value: matches,
            height: 240,
            onRetry: () => ref.invalidate(fridgeMatchesProvider),
            data: (matches) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _results(matches),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _results(List<RecipeMatch> matches) {
    final ready = _sorted(matches.where((m) => m.isReady));
    final almost = _sorted(matches.where((m) => !m.isReady));
    return [
      if (matches.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.muted),
              SizedBox(height: 12),
              Text(
                'No matches yet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Try adding a few more ingredients.',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      if (ready.isNotEmpty) ...[
        const SizedBox(height: 22),
        _GroupHeader(
          icon: Icons.check_circle_outline,
          title: 'Ready to cook',
          count: ready.length,
          color: AppColors.success,
          tint: AppColors.successTint,
        ),
        for (final m in ready) ...[
          const SizedBox(height: 12),
          _MatchCard(match: m),
        ],
      ],
      if (almost.isNotEmpty) ...[
        const SizedBox(height: 26),
        _GroupHeader(
          icon: Icons.schedule,
          title: 'Almost there',
          subtitle: 'Missing just 1–2 ingredients',
          count: almost.length,
          color: AppColors.accentDark,
          tint: AppColors.accentTint,
        ),
        for (final m in almost) ...[
          const SizedBox(height: 12),
          _MatchCard(match: m),
        ],
      ],
    ];
  }
}

class _IngredientsSummary extends StatelessWidget {
  const _IngredientsSummary({required this.selected});

  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSoft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Using ${selected.length} ingredients',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Edit'),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final name in selected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentDark,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({required this.value, required this.onChanged});

  final _Sort value;
  final ValueChanged<_Sort> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(_Sort sort, String label) {
      final active = value == sort;
      return Expanded(
        child: Material(
          color: active ? AppColors.surface : Colors.transparent,
          elevation: active ? 1 : 0,
          shadowColor: const Color(0x331F1A17),
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: () => onChanged(sort),
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: active ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.segment,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          option(_Sort.bestMatch, 'Best match'),
          const SizedBox(width: 4),
          option(_Sort.quickest, 'Quickest'),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.tint,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int count;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final recipe = match.recipe;
    final ready = match.isReady;
    final barColor = ready ? AppColors.success : AppColors.accent;
    final trackColor = ready ? AppColors.successTint : AppColors.accentTrack;
    final labelColor = ready ? AppColors.success : AppColors.accentDark;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {}, // TODO: recipe detail
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  RecipeThumb(recipe: recipe, size: const Size.square(84)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recipe.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${match.have} of ${match.need} ingredients',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: match.ratio,
                            minHeight: 6,
                            color: barColor,
                            backgroundColor: trackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!ready) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 13),
                          children: [
                            const TextSpan(
                              text: 'Missing: ',
                              style: TextStyle(color: AppColors.muted),
                            ),
                            TextSpan(
                              text: match.missing.join(', '),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        // TODO: real shopping list.
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Shopping list is coming soon'),
                          ),
                        ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                      ),
                      child: const Text('+ Shopping list'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
