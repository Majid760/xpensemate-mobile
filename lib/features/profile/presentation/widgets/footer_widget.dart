import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class ModernFooter extends StatelessWidget {
  const ModernFooter({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.lg),
        margin: EdgeInsets.symmetric(horizontal: context.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primary.withValues(alpha: 0.03),
              context.colorScheme.secondary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(context.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(height: context.md),
            Text(
              context.l10n.expenseTracker,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.xs),
            Text(
              context.l10n.version,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.craftedWithLove,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
