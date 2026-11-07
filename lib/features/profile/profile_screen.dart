import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: auth.isLoggedIn
                  ? [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFFFE4D6),
                        child: Text(
                          auth.email![0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.email!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(authControllerProvider.notifier).logout(),
                        child: const Text('Log out'),
                      ),
                    ]
                  : [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 56,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Join the kitchen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Log in to keep your saved recipes and fridge across devices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.login),
                        child: const Text('Log in'),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
