import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import '../theme/app_colors.dart';

/// Shows [data] once [value] has loaded, a spinner while it loads, and an
/// error message with a Retry button if it failed.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.onRetry,
    required this.data,
    this.height = 120,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  /// Height of the loading and error placeholders.
  final double height;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is ApiException
                      ? error.message
                      : 'Something went wrong. Please try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
