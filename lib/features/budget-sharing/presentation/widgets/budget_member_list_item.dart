import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class BudgetMemberListItem extends StatelessWidget {
  const BudgetMemberListItem({
    super.key,
    required this.name,
    required this.email,
    this.spentAmount,
    required this.initials,
    required this.role,
    required this.roleColor,
    required this.roleTextColor,
    this.showMenu = true,
    this.onMenuPressed,
  });

  final String name;
  final String email;
  final String? spentAmount;
  final String initials;
  final String role;
  final Color roleColor;
  final Color roleTextColor;
  final bool showMenu;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm1,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primary.withValues(alpha: 0.1),
            child: Text(
              initials,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  spentAmount != null ? '$email · $spentAmount spent' : email,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: roleColor,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              role,
              style: context.textTheme.labelSmall?.copyWith(
                color: roleTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
          if (showMenu) ...[
            const SizedBox(width: AppSpacing.xs),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.more_vert, size: 16),
                color: scheme.onSurface.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}