import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class _StatsMember {
  const _StatsMember({
    required this.name,
    required this.initials,
    required this.role,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.avatarColor,
    required this.avatarTextColor,
    required this.roleColor,
    required this.roleTextColor,
  });

  final String name;
  final String initials;
  final String role;
  final String amount;
  final int percentage;
  final Color color;
  final Color avatarColor;
  final Color avatarTextColor;
  final Color roleColor;
  final Color roleTextColor;
}

class BudgetMembersStatsTab extends StatelessWidget {
  const BudgetMembersStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    // Stub data matching the image UI
    final statsMembers = [
      _StatsMember(
        name: 'Sara Raza',
        initials: 'SR',
        role: context.l10n.editor,
        amount: r'$12',
        percentage: 71,
        color: const Color(0xFF2E7D32), // Custom green for visual matching or scheme.primary
        avatarColor: isDark ? const Color(0xFF64B5F6).withValues(alpha: 0.4) : scheme.primaryContainer,
        avatarTextColor: isDark ? const Color(0xFF64B5F6) : scheme.onPrimaryContainer,
        roleColor: isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHighest,
        roleTextColor: isDark ? const Color(0xFF64B5F6) : scheme.primary,
      ),
      _StatsMember(
        name: 'Nadia Fatima',
        initials: 'NF',
        role: context.l10n.editor,
        amount: r'$5',
        percentage: 29,
        color: const Color(0xFF5E35B1), // Custom purple for visual matching or scheme.secondary
        avatarColor: isDark ? scheme.surfaceContainerHighest : scheme.secondaryContainer,
        avatarTextColor: isDark ? scheme.onSurface : scheme.onSecondaryContainer,
        roleColor: isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHighest,
        roleTextColor: isDark ? const Color(0xFF64B5F6) : scheme.primary,
      ),
      _StatsMember(
        name: 'Ahmed Khan',
        initials: 'AK',
        role: context.l10n.viewer,
        amount: r'$0',
        percentage: 0,
        color: Colors.transparent,
        avatarColor: isDark ? const Color(0xFFE57373).withValues(alpha: 0.4) : scheme.tertiaryContainer,
        avatarTextColor: isDark ? const Color(0xFFE57373) : scheme.onTertiaryContainer,
        roleColor: isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHighest,
        roleTextColor: isDark ? scheme.onSurface.withValues(alpha: 0.6) : scheme.onSurface.withValues(alpha: 0.6),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm1),
            child: Text(
              context.l10n.spendingContribution.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface.withValues(alpha: 0.8),
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // Contribution Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHighest.withValues(alpha: 0.2) : scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: statsMembers.asMap().entries.map((entry) {
                final isLast = entry.key == statsMembers.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md1),
                  child: _StatsMemberRow(member: entry.value),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // 4 Grid cards
          Row(
            children: [
              Expanded(child: _SummaryCard(value: r'$17', label: context.l10n.totalSpent)),
              const SizedBox(width: AppSpacing.sm1),
              Expanded(child: _SummaryCard(value: r'$6', label: context.l10n.remaining)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm1),
          Row(
            children: [
              Expanded(child: _SummaryCard(value: '4', label: context.l10n.activeMembersLabel)),
              const SizedBox(width: AppSpacing.sm1),
              Expanded(child: _SummaryCard(value: '2', label: context.l10n.pendingInvitesLabel)),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _StatsMemberRow extends StatelessWidget {
  const _StatsMemberRow({required this.member});

  final _StatsMember member;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: member.avatarColor,
          child: Text(
            member.initials,
            style: context.textTheme.titleSmall?.copyWith(
              color: member.avatarTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    member.name,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: member.roleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      member.role,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: member.roleTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Amount / percentage
                  Text(
                    context.l10n.spentWithPercentage(member.amount, member.percentage),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Progress bar
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: member.percentage / 100),
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value > 0 ? value : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: member.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHighest.withValues(alpha: 0.2) : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
