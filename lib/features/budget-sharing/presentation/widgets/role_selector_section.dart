import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

/// A selectable chip for picking a member's role.
class RoleChip extends StatelessWidget {
  const RoleChip({
    super.key,
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.xxl),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outline.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: isSelected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Row of role selection chips labelled with a "CHANGE ROLE" header.
class RoleSelectorSection extends StatelessWidget {
  const RoleSelectorSection({
    super.key,
    required this.selectedRole,
    required this.availableRoles,
    required this.onRoleSelected,
  });

  final String selectedRole;
  final List<String> availableRoles;
  final void Function(String) onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: scheme.outline.withValues(alpha: 0.15), height: 1),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.changeRole.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm1),
        Wrap(
          spacing: AppSpacing.sm,
          children: availableRoles
              .map(
                (role) => RoleChip(
                  label: role,
                  isSelected: selectedRole == role,
                  onTap: () => onRoleSelected(role),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
