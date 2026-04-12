import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/features/budget-sharing/presentation/pages/budget_members_page.dart';

class ShareBudgetSheet {
  const ShareBudgetSheet._();

  static Future<void> show({
    required BuildContext context,
  }) =>
      AppBottomSheet.show<void>(
        context: context,
        config: BottomSheetConfig(
          showCloseButton: false, // We include our custom title row
          height: context.screenHeight * 0.85,
          blurSigma: 6,
        ),
        child: const _ShareBudgetSheetContent(),
      );
}

class _ShareBudgetSheetContent extends StatefulWidget {
  const _ShareBudgetSheetContent();

  @override
  State<_ShareBudgetSheetContent> createState() => _ShareBudgetSheetContentState();
}

class _ShareBudgetSheetContentState extends State<_ShareBudgetSheetContent> {
  String _selectedRole = 'Editor';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.shareBudget,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: scheme.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // INVITE BY EMAIL Label
          Text(
            context.l10n.inviteByEmailTitle,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // TextField and Invite Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: context.l10n.searchNameOrEmail,
                    hintStyle: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: isDark ? scheme.surfaceContainerHighest.withValues(alpha: 0.2) : scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? scheme.surfaceContainerHighest : scheme.primaryContainer,
                  foregroundColor: isDark ? scheme.onSurface : scheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md1, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.inviteButtonLabel,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md1),

          // ROLE Label
          Text(
            context.l10n.roleTitleLabel,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Roles Filter Chips inside a Row
          Row(
            children: [
              _RoleChip(
                label: context.l10n.editor,
                isSelected: _selectedRole == context.l10n.editor,
                onTap: () => setState(() => _selectedRole = context.l10n.editor),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RoleChip(
                label: context.l10n.viewer,
                isSelected: _selectedRole == context.l10n.viewer,
                onTap: () => setState(() => _selectedRole = context.l10n.viewer),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md1),

          // PENDING INVITES Label
          Text(
            context.l10n.pendingInvitesTitleLabel,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Pending List
          _MiniPendingInviteRow(
            initials: 'ZA',
            email: 'zara@email.com',
            sentText: context.l10n.daysAgo(2),
            avatarColor: context.colorScheme.tertiaryContainer,
            avatarTextColor: context.colorScheme.onTertiaryContainer,
          ),
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          _MiniPendingInviteRow(
            initials: 'FM',
            email: 'fatima@email.com',
            sentText: context.l10n.daysAgo(5),
            avatarColor: context.colorScheme.secondaryContainer,
            avatarTextColor: context.colorScheme.onSecondaryContainer,
          ),
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          
          const SizedBox(height: AppSpacing.lg),

          // Manage Members Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (context) => const BudgetMembersPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? scheme.surfaceContainerHighest.withValues(alpha: 0.5) : scheme.surface,
                foregroundColor: scheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                context.l10n.manageMembersButton,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? scheme.primary.withValues(alpha: 0.2) : scheme.primaryContainer) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MiniPendingInviteRow extends StatelessWidget {
  const _MiniPendingInviteRow({
    required this.initials,
    required this.email,
    required this.sentText,
    required this.avatarColor,
    required this.avatarTextColor,
  });

  final String initials;
  final String email;
  final String sentText;
  final Color avatarColor;
  final Color avatarTextColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm1),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDark ? avatarColor.withValues(alpha: 0.4) : avatarColor,
            radius: 20,
            child: Text(
              initials,
              style: context.textTheme.titleSmall?.copyWith(
                color: isDark ? avatarTextColor : avatarTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sentText,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm1, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              context.l10n.pending,
              style: context.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.orange.shade300 : Colors.orange.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
