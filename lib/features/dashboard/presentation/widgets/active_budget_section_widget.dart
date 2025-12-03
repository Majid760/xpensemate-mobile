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
        padding: EdgeInsets.all(context.md),
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
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.md),
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
              SectionHeaderWidget(
                title: context.l10n.activeBudgets,
                icon: Icons.account_balance_wallet_outlined,
                action: AppButton.textButton(
                  text: context.l10n.seeDetail,
                  textColor: context.primaryColor,
                  onPressed: context.goToBudget,
                ),
              ),
              SizedBox(height: context.lg),
              // Budget List
              _BudgetList(budgetGoals: budgetGoals),
            ],
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
      builder: (context, constraints) => Column(
        children: [
          ...activeGoals.map(
            (goal) => Padding(
              padding: EdgeInsets.only(bottom: context.md),
              child: BudgetCard(goal: goal),
            ),
          ),
          AppButton.textButton(
            text: context.l10n.seeDetail,
            textColor: context.primaryColor,
            onPressed: context.goToBudget,
          ),
        ],
      ),
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
              Icons.bubble_chart,
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

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  final BudgetGoalEntity goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = goal.setBudget > 0
        ? (goal.currentSpending / goal.setBudget).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.setBudget - goal.currentSpending;
    final status = _getBudgetStatus(progress);

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
              padding: EdgeInsets.all(isCompact ? 12 : 16),
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
                  SizedBox(height: isCompact ? 12 : 16),
                  _ProgressSection(
                    progress: progress,
                    status: status,
                    isCompact: isCompact,
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
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

  _BudgetStatusData _getBudgetStatus(double progress) {
    if (progress >= 1.0) {
      return const _BudgetStatusData(
        label: 'overBudget',
        color: Color(0xFFEF4444),
        icon: Icons.warning_rounded,
      );
    } else if (progress >= 0.8) {
      return const _BudgetStatusData(
        label: 'nearLimit',
        color: Color(0xFFF59E0B),
        icon: Icons.warning_amber_rounded,
      );
    } else if (progress >= 0.5) {
      return const _BudgetStatusData(
        label: 'moderate',
        color: Color(0xFF6366F1),
        icon: Icons.trending_up_rounded,
      );
    } else {
      return const _BudgetStatusData(
        label: 'onTrack',
        color: Color(0xFF10B981),
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
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
    final data = _getPriorityData(priority.toLowerCase());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
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

  _PriorityInfo _getPriorityData(String priority) {
    switch (priority) {
      case 'high':
        return const _PriorityInfo(
          label: 'HIGH',
          color: Color(0xFFEF4444),
          icon: Icons.priority_high_rounded,
        );
      case 'medium':
        return const _PriorityInfo(
          label: 'MED',
          color: Color(0xFF6366F1),
          icon: Icons.remove_rounded,
        );
      case 'low':
      default:
        return const _PriorityInfo(
          label: 'LOW',
          color: Color(0xFF10B981),
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
                    _getStatusText(status.label, context),
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

  String _getStatusText(String label, BuildContext context) {
    switch (label) {
      case 'overBudget':
        return 'Over Budget';
      case 'nearLimit':
        return 'Near Limit';
      case 'moderate':
        return 'Moderate';
      case 'onTrack':
      default:
        return 'On Track';
    }
  }
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
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _AmountItem(
                label: 'Spent',
                amount: spent,
                color: Theme.of(context).colorScheme.onSurface,
                icon: Icons.arrow_upward_rounded,
                isCompact: isCompact,
              ),
            ),
            Container(
              width: 1,
              height: isCompact ? 32 : 40,
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _AmountItem(
                label: 'Left',
                amount: remaining,
                color: status.color,
                icon: Icons.account_balance_wallet_rounded,
                isCompact: isCompact,
              ),
            ),
            Container(
              width: 1,
              height: isCompact ? 32 : 40,
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _AmountItem(
                label: 'Budget',
                amount: total,
                color: const Color(0xFF6366F1),
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
