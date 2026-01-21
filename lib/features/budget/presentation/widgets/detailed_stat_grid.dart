import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/presentation/widgets/stat_card.dart';

class DetailedStatsGrid extends StatelessWidget {
  const DetailedStatsGrid({super.key, this.budgetGoalsInsight});
  final BudgetGoalsInsightEntity? budgetGoalsInsight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: Icons.cancel_outlined,
                value:
                    '${budgetGoalsInsight?.failedGoals.length ?? 0}/${budgetGoalsInsight?.terminatedGoals.length ?? 0}',
                label: l10n.failedTerminated,
                subtitle: l10n.goalsNotCompleted,
                color: context.theme.primaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatsCard(
                icon: Icons.attach_money_rounded,
                value: AppUtils.formatLargeNumber(
                  budgetGoalsInsight?.totalBudgeted ?? 0.0,
                ),
                label: l10n.totalBudgeted,
                subtitle: l10n.totalAmountAllocated,
                color: context.theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: Icons.analytics_outlined,
                value:
                    '${budgetGoalsInsight?.avgProgress.toStringAsFixed(1) ?? '0.0'}%',
                label: l10n.avgProgress,
                subtitle: l10n.averageProgressGoals,
                color: context.theme.primaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatsCard(
                icon: Icons.event_outlined,
                value:
                    budgetGoalsInsight?.closestDeadlineDate ?? l10n.noDeadlines,
                label: l10n.closestDeadline,
                subtitle: l10n.nextUpcomingDeadline,
                color: context.theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        StatsCard(
          icon: Icons.schedule_rounded,
          value: '${budgetGoalsInsight?.overdueGoals.length ?? 0}',
          label: l10n.overdueGoals,
          subtitle: l10n.goalsPastDeadline,
          color: context.theme.primaryColor,
        ),
      ],
    );
  }
}
