import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/section_header_widget.dart';

class ActiveBudgetSectionWidget extends StatelessWidget {
  const ActiveBudgetSectionWidget({
    super.key,
    required this.budgetGoals,
  });

  final BudgetGoalsEntity budgetGoals;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.lg),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: context.colorScheme.primary.withValues(alpha: 0.02),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SectionHeaderWidget(
              title: context.l10n.activeBudgets,
              icon: Icons.account_balance_wallet_outlined,
              action: AppButton.textButton(
                text: context.l10n.seeDetail,
                textColor: context.primaryColor,
                onPressed: context.goToDashboard,
              ),
            ),
            SizedBox(height: context.lg),

            // Budget List
            _BudgetList(budgetGoals: budgetGoals),
          ],
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
                padding: EdgeInsets.only(bottom: context.md),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: goals
            .asMap()
            .entries
            .map(
              (entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key < goals.length - 1 ? context.md : 0,
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
    final status = _getBudgetStatus(progress, context);

    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.surface,
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            context.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.color.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
          SizedBox(height: context.md),

          // Progress Bar
          _ProgressBar(
            progress: progress,
            color: status.color,
          ),
          SizedBox(height: context.md),

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

  _BudgetStatus _getBudgetStatus(double progress, BuildContext context) {
    if (progress >= 1) {
      return _BudgetStatus(
        label: 'overBudget',
        color: context.colorScheme.error,
        backgroundColor: context.colorScheme.error,
      );
    } else if (progress >= 0.8) {
      return _BudgetStatus(
        label: 'nearLimit',
        color: context.colorScheme.secondary,
        backgroundColor: context.colorScheme.secondary,
      );
    } else {
      return _BudgetStatus(
        label: 'onTrack',
        color: context.colorScheme.primary,
        backgroundColor: context.colorScheme.primary,
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
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: context.xs),
                Text(
                  category,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
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
    final priorityData = _getPriorityData(priority.toLowerCase(), context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            priorityData.color.withValues(alpha: 0.15),
            priorityData.color.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: priorityData.color.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        priorityData.label,
        style: context.textTheme.labelSmall?.copyWith(
          color: priorityData.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _PriorityData _getPriorityData(String priority, BuildContext context) {
    switch (priority) {
      case 'high':
        return _PriorityData(
          label: context.l10n.highPriority,
          color: context.colorScheme.error,
        );
      case 'medium':
        return _PriorityData(
          label: context.l10n.mediumPriority,
          color: context.colorScheme.secondary,
        );
      case 'low':
      default:
        return _PriorityData(
          label: context.l10n.lowPriority,
          color: context.colorScheme.primary,
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
        height: 10,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                colors: [
                  color.withValues(alpha: 0.7),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(spent),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.l10n.spent,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(remaining),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.l10n.remaining,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
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
        horizontal: context.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            status.color.withValues(alpha: 0.15),
            status.color.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        statusText,
        style: context.textTheme.labelSmall?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
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
