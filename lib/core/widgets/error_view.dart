import 'package:flutter/material.dart';

/// Reusable error view widget
class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final IconData icon;

  // TODO(manus): Deprecated parameter name 'message' - use 'error' instead
  // Keeping both for backward compatibility
  String get message => error;

  const ErrorView({
    Key? key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ', // An error occurred
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('حاول مرة أخرى'), // Try again
              ),
            ],
          ],
        ),
      ),
    );
  }
}

