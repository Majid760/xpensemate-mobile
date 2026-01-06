import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  final BudgetGoalDashboardEntity goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = goal.setBudget > 0
        ? (goal.currentSpending / goal.setBudget).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.setBudget - goal.currentSpending;
    final status = _getBudgetStatus(progress, context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 350;

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: status.color.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(isCompact ? context.sm1 : context.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    status.color.withValues(alpha: 0.03),
                    Colors.transparent,
                    status.color.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BudgetHeader(
                    name: goal.name,
                    category: goal.category,
                    priority: goal.priority,
                    isCompact: isCompact,
                  ),
                  SizedBox(height: isCompact ? context.sm1 : context.md),
                  _ProgressSection(
                    progress: progress,
                    status: status,
                    isCompact: isCompact,
                  ),
                  SizedBox(height: isCompact ? context.sm1 : context.md),
                  _AmountSection(
                    spent: goal.currentSpending,
                    remaining: remaining,
                    total: goal.setBudget,
                    status: status,
                    isCompact: isCompact,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _BudgetStatusData _getBudgetStatus(double progress, BuildContext context) {
    if (progress >= 1.0) {
      return _BudgetStatusData(
        label: context.l10n.overBudget,
        color: context.colorScheme.error,
        icon: Icons.warning_rounded,
      );
    } else if (progress >= 0.8) {
      return _BudgetStatusData(
        label: context.l10n.nearLimit, // Localized
        color: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      );
    } else if (progress >= 0.5) {
      return _BudgetStatusData(
        label: context.l10n.moderate, // Localized
        color: context.colorScheme.primary,
        icon: Icons.trending_up_rounded,
      );
    } else {
      return _BudgetStatusData(
        label: context.l10n.onTrack, // Localized
        color: AppColors.success,
        icon: Icons.check_circle_rounded,
      );
    }
  }
}

// ==================== Header Section ====================
class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({
    required this.name,
    required this.category,
    required this.priority,
    required this.isCompact,
  });

  final String name;
  final String category;
  final String priority;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.xs / 2),
                Text(
                  category,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: isCompact ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: context.sm),
          _PriorityBadge(priority: priority, isCompact: isCompact),
        ],
      );
}

// ==================== Priority Badge ====================
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.priority,
    required this.isCompact,
  });

  final String priority;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final data = _getPriorityData(priority.toLowerCase(), context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? context.sm : context.sm1,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: data.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.icon,
            size: isCompact ? 12 : 14,
            color: data.color,
          ),
          const SizedBox(width: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: data.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _PriorityInfo _getPriorityData(String priority, BuildContext context) {
    switch (priority) {
      case 'high':
        return _PriorityInfo(
          label: context.l10n.highPriority.toUpperCase(), // Localized
          color: context.colorScheme.error,
          icon: Icons.priority_high_rounded,
        );
      case 'medium':
        return _PriorityInfo(
          label: context.l10n.mediumPriorityAbbr.toUpperCase(), // Localized
          color: context.colorScheme.primary,
          icon: Icons.remove_rounded,
        );
      case 'low':
      default:
        return _PriorityInfo(
          label: context.l10n.lowPriority.toUpperCase(), // Localized
          color: AppColors.success,
          icon: Icons.trending_down_rounded,
        );
    }
  }
}

// ==================== Progress Section ====================
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.status,
    required this.isCompact,
  });

  final double progress;
  final _BudgetStatusData status;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status.icon,
                    size: isCompact ? 14 : 16,
                    color: status.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status.label,
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: status.color,
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: status.color,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 10),
          _AnimatedProgressBar(
            progress: progress,
            color: status.color,
            height: isCompact ? 6 : 8,
          ),
        ],
      );
}

// ==================== Amount Section ====================
class _AmountSection extends StatelessWidget {
  const _AmountSection({
    required this.spent,
    required this.remaining,
    required this.total,
    required this.status,
    required this.isCompact,
  });

  final double spent;
  final double remaining;
  final double total;
  final _BudgetStatusData status;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(isCompact ? 12 : 14),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _AmountItem(
                label: context.l10n.spent,
                amount: spent,
                color: context.colorScheme.onSurface,
                icon: Icons.arrow_upward_rounded,
                isCompact: isCompact,
              ),
            ),
            Container(
              width: 1,
              height: isCompact ? 32 : 40,
              color: context.colorScheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _AmountItem(
                label: context.l10n.remaining,
                amount: remaining,
                color: status.color,
                icon: Icons.account_balance_wallet_rounded,
                isCompact: isCompact,
              ),
            ),
            Container(
              width: 1,
              height: isCompact ? 32 : 40,
              color: context.colorScheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _AmountItem(
                label: context.l10n.budget,
                amount: total,
                color: context.colorScheme.primary,
                icon: Icons.savings_rounded,
                isCompact: isCompact,
              ),
            ),
          ],
        ),
      );
}

// ==================== Amount Item ====================
class _AmountItem extends StatelessWidget {
  const _AmountItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isCompact,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isCompact ? 16 : 18,
            color: color.withValues(alpha: 0.7),
          ),
          SizedBox(height: isCompact ? 4 : 6),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: isCompact ? 13 : 15,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
}

// ==================== Helper Classes ====================
class _BudgetStatusData {
  const _BudgetStatusData({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class _PriorityInfo {
  const _PriorityInfo({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

// ==================== Animated Progress Bar ====================
class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({
    required this.progress,
    required this.color,
    required this.height,
  });

  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
