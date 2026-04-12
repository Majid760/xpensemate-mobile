import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

class PendingInviteCard extends StatelessWidget {
  const PendingInviteCard({
    super.key,
    required this.email,
    required this.initials,
    required this.roleDescription,
    required this.statusLabel,
    required this.revokeLabel,
    required this.resendLabel,
    required this.onRevoke,
    required this.onResend,
  });

  final String email;
  final String initials;
  final String roleDescription;
  final String statusLabel;
  final String revokeLabel;
  final String resendLabel;
  final VoidCallback onRevoke;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Top Row: Avatar, Info, Badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                child: Text(
                  initials,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
                      email,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleDescription,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Pending Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Bottom Row: Actions
          Row(
            children: [
              Expanded(
                child:AppButton.outline(
                  height: 40,
                  text: revokeLabel,
                  textColor: scheme.error,
                  padding: EdgeInsets.zero,
                  borderColor: scheme.error,
                  backgroundColor: scheme.errorContainer.withValues(alpha: 0.6),
                  onPressed: onRevoke,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child:AppButton.outline(
                  height: 40,
                  text: resendLabel,
                  textColor: scheme.primary,
                  padding: EdgeInsets.zero,
                  borderColor: scheme.primary,
                  backgroundColor: scheme.primaryContainer.withValues(alpha: 0.6),
                  onPressed: onResend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
