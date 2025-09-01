import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';

class ActiveBudgetSectionWidget extends StatelessWidget {
  const ActiveBudgetSectionWidget({
    super.key,
    required this.budgetGoals,
  });

  final BudgetGoalsEntity budgetGoals;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.md),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const _SectionHeader(),
            SizedBox(height: context.md),

            // Budget List
            _BudgetList(budgetGoals: budgetGoals),
          ],
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(
            Icons.savings_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          SizedBox(width: context.xs),
          Expanded(
            child: Text(
              context.l10n.activeBudgets,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const _CreateBudgetButton(),
        ],
      );
}

class _CreateBudgetButton extends StatelessWidget {
  const _CreateBudgetButton();

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.sm,
              vertical: context.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
                SizedBox(width: context.xs),
                Text(
                  context.l10n.createBudget,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BudgetList extends StatelessWidget {
  const _BudgetList({
    required this.budgetGoals,
  });

  final BudgetGoalsEntity budgetGoals;

  @override
  Widget build(BuildContext context) {
    final activeGoals = budgetGoals.goals
        .where((goal) => goal.status.toLowerCase() != 'completed')
        .take(3) // Show maximum 3 active budgets
        .toList();

    if (activeGoals.isEmpty) {
      return const _EmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        if (isTablet) {
          return _TabletLayout(goals: activeGoals);
        } else {
          return _MobileLayout(goals: activeGoals);
        }
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        height: 120,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 32,
              color: context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.noBudgetsActive,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.goals,
  });

  final List<BudgetGoalEntity> goals;

  @override
  Widget build(BuildContext context) => Column(
        children: goals
            .map(
              (goal) => Padding(
                padding: EdgeInsets.only(bottom: context.sm),
                child: _BudgetCard(goal: goal),
              ),
            )
            .toList(),
      );
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.goals,
  });

  final List<BudgetGoalEntity> goals;

  @override
  Widget build(BuildContext context) => Row(
        children: goals
            .asMap()
            .entries
            .map(
              (entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key < goals.length - 1 ? context.sm : 0,
                  ),
                  child: _BudgetCard(goal: entry.value),
                ),
              ),
            )
            .toList(),
      );
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.goal,
  });

  final BudgetGoalEntity goal;

  @override
  Widget build(BuildContext context) {
    final progress = goal.setBudget > 0
        ? (goal.currentSpending / goal.setBudget).clamp(0.0, 1.0)
        : 0.0;

    final remaining = goal.setBudget - goal.currentSpending;
    final status = _getBudgetStatus(progress);

    return Container(
      padding: EdgeInsets.all(context.sm),
      decoration: BoxDecoration(
        color: status.backgroundColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Name and Priority
          _BudgetHeader(
            name: goal.name,
            category: goal.category,
            priority: goal.priority,
          ),
          SizedBox(height: context.sm),

          // Progress Bar
          _ProgressBar(
            progress: progress,
            color: status.color,
          ),
          SizedBox(height: context.sm),

          // Budget Details
          _BudgetDetails(
            spent: goal.currentSpending,
            remaining: remaining,
            total: goal.setBudget,
            status: status,
          ),
        ],
      ),
    );
  }

  _BudgetStatus _getBudgetStatus(double progress) {
    if (progress >= 1.0) {
      return const _BudgetStatus(
        label: 'overBudget',
        color: AppColors.error,
        backgroundColor: AppColors.error,
      );
    } else if (progress >= 0.8) {
      return const _BudgetStatus(
        label: 'nearLimit',
        color: AppColors.warning,
        backgroundColor: AppColors.warning,
      );
    } else {
      return const _BudgetStatus(
        label: 'onTrack',
        color: AppColors.success,
        backgroundColor: AppColors.success,
      );
    }
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({
    required this.name,
    required this.category,
    required this.priority,
  });

  final String name;
  final String category;
  final String priority;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: context.xs),
                Text(
                  category,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          _PriorityChip(priority: priority),
        ],
      );
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
  });

  final String priority;

  @override
  Widget build(BuildContext context) {
    final priorityData = _getPriorityData(priority.toLowerCase());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: priorityData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priorityData.label,
        style: context.textTheme.bodySmall?.copyWith(
          color: priorityData.color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  _PriorityData _getPriorityData(String priority) {
    switch (priority) {
      case 'high':
        return const _PriorityData(
          label: 'High',
          color: AppColors.error,
        );
      case 'medium':
        return const _PriorityData(
          label: 'Medium',
          color: AppColors.warning,
        );
      case 'low':
      default:
        return const _PriorityData(
          label: 'Low',
          color: AppColors.success,
        );
    }
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        height: 6,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
}

class _BudgetDetails extends StatelessWidget {
  const _BudgetDetails({
    required this.spent,
    required this.remaining,
    required this.total,
    required this.status,
  });

  final double spent;
  final double remaining;
  final double total;
  final _BudgetStatus status;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CurrencyFormatter.format(spent)} ${context.l10n.spent}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyFormatter.format(remaining)} ${context.l10n.remaining}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _StatusChip(status: status),
        ],
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final _BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    String statusText;
    switch (status.label) {
      case 'overBudget':
        statusText = context.l10n.overBudget;
        break;
      case 'nearLimit':
        statusText = context.l10n.nearLimit;
        break;
      case 'onTrack':
      default:
        statusText = context.l10n.onTrack;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: context.textTheme.bodySmall?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

// Helper classes
class _BudgetStatus {
  const _BudgetStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}

class _PriorityData {
  const _PriorityData({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}
