import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

class BudgetMember {

  const BudgetMember({
    required this.name,
    required this.email,
    required this.initials,
    required this.role,
    required this.avatarColor,
    required this.roleColor,
    required this.roleTextColor,
  });
  final String name;
  final String email;
  final String initials;
  final String role;
  final Color avatarColor;
  final Color roleColor;
  final Color roleTextColor;
}

class BudgetMembersCard extends StatelessWidget {
  const BudgetMembersCard({
    super.key,
    required this.members,
    required this.onViewAll,
  });

  final List<BudgetMember> members;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
                AppButton.outline(
                height: 36,
                minWidth: 80,
                isFullWidth: false,
                borderRadius: 10,
                text: 'View all',
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                textColor: scheme.primary,
                borderColor: scheme.primary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onPressed: onViewAll,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMemberRow(context, m),
              ),),
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, BudgetMember member) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primary.withValues(alpha: 0.1),
          child: Text(
            member.initials,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                member.email,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: member.roleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            member.role,
            style: context.textTheme.labelMedium?.copyWith(
              color: member.roleTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
