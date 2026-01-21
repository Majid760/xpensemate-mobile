import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

class RetryWidget extends StatelessWidget {
  const RetryWidget({super.key, this.onRetry, this.message});
  final void Function()? onRetry;
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth - 32,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: context.colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? context.l10n.errorLoadingBudgets,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          AppButton.icon(
            text: context.l10n.retry,
            onPressed: onRetry,
            leadingIcon: const Icon(Icons.refresh, size: 24),
          ),
        ],
      ),
    );
  }
}
