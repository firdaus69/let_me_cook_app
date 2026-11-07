import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/recipe_repository.dart';

/// Pill button showing the current country; opens a sheet to change it.
class CountryPickerButton extends ConsumerWidget {
  const CountryPickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(countryProvider);

    return OutlinedButton.icon(
      onPressed: () => _showPicker(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.surface,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
      ),
      icon: const Icon(
        Icons.location_on_outlined,
        size: 18,
        color: AppColors.accent,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.name),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(countryProvider);
    final countries = ref.read(countriesProvider).value ?? [current];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Recipes from',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            for (final c in countries)
              ListTile(
                title: Text(c.name),
                trailing: c == current
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () {
                  ref.read(countryProvider.notifier).select(c);
                  Navigator.pop(context);
                },
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                'More countries coming soon.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
