import 'package:flutter/material.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class RetryWidget extends StatelessWidget {
  const RetryWidget({super.key, this.onRetry, this.message});
  final void Function()? onRetry;
  final String? message;
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? localizations?.budgetGoalsError ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 12),
          AppButton.icon(
            text: localizations?.budgetGoalsRetry ?? 'Retry',
            onPressed: onRetry,
            leadingIcon: const Icon(Icons.refresh, size: 24),
          ),
        ],
      ),
    );
  }
}
