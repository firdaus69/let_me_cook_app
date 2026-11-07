import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../fridge/fridge_controller.dart';

/// Entry point to the main "Cook from your fridge" feature.
class FridgeHeroCard extends ConsumerWidget {
  const FridgeHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(fridgeControllerProvider).selected.toList();
    final preview = selected.take(3).toList();
    final extra = selected.length - preview.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -36,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            right: 18,
            top: 18,
            child: Icon(Icons.kitchen_outlined, size: 56, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Pill('CUSTOM', filled: true, letterSpacing: 0.8),
                const SizedBox(height: 14),
                const SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cook from your fridge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Pick the ingredients you already have. We'll find recipes you can make right now.",
                        style: TextStyle(
                          color: Color(0xFFE7DFD8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in preview) _Pill(name, filled: true),
                    if (extra > 0) _Pill('+$extra more', filled: true),
                    _Pill(
                      selected.isEmpty ? '+ Add ingredients' : '+ Add more',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.fridge),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                      minimumSize: const Size.fromHeight(52),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Open my fridge'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {this.filled = false, this.letterSpacing});

  final String label;
  final bool filled;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? Colors.white.withValues(alpha: 0.12) : null,
        border: filled
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: letterSpacing != null ? 12 : 13,
          letterSpacing: letterSpacing,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
