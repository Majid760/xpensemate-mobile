import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/presentation/widgets/stat_card.dart';

class ExpandableStatsCard extends StatefulWidget {
  const ExpandableStatsCard(
      {super.key, this.budgetGoalsInsight, required this.period});
  final BudgetGoalsInsightEntity? budgetGoalsInsight;
  final String period;

  @override
  State<ExpandableStatsCard> createState() => _ExpandableStatsCardState();
}

class _ExpandableStatsCardState extends State<ExpandableStatsCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.primaryColor,
              context.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.overview,
                              style: (context.textTheme.titleMedium ??
                                      const TextStyle())
                                  .copyWith(
                                color: context.colorScheme.onPrimary
                                    .withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${widget.period.capitalize} ${context.budgetStatistics}',
                              style: (context.textTheme.headlineSmall ??
                                      const TextStyle())
                                  .copyWith(
                                color: context.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: context.colorScheme.onPrimary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.radiusMedium,
                              ),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.colorScheme.onPrimary,
                              size: AppSpacing.iconLg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    QuickStatsRow(
                      budgetGoalsInsight: widget.budgetGoalsInsight,
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1,
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.onPrimary
                                      .withValues(alpha: 0),
                                  context.colorScheme.onPrimary
                                      .withValues(alpha: 0.3),
                                  context.colorScheme.onPrimary
                                      .withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          DetailedStatsGrid(
                            budgetGoalsInsight: widget.budgetGoalsInsight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class DetailedStatsGrid extends StatelessWidget {
  const DetailedStatsGrid({super.key, this.budgetGoalsInsight});
  final BudgetGoalsInsightEntity? budgetGoalsInsight;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  icon: Icons.cancel_outlined,
                  value:
                      '${budgetGoalsInsight?.failedGoals.length ?? 0}/${budgetGoalsInsight?.terminatedGoals.length ?? 0}',
                  label: context.failedTerminated,
                  subtitle: context.goalsNotCompleted,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsCard(
                  icon: Icons.attach_money_rounded,
                  value: AppUtils.formatLargeNumber(
                      budgetGoalsInsight?.totalBudgeted ?? 0.0),
                  label: context.totalBudgeted,
                  subtitle: context.totalAmountAllocated,
                  color: context.primaryColor,
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
                  label: context.avgProgress,
                  subtitle: context.averageProgressGoals,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsCard(
                  icon: Icons.event_outlined,
                  value:
                      budgetGoalsInsight?.closestDeadlineDate.toFormattedDate ??
                          context.noDeadlines,
                  label: context.closestDeadline,
                  subtitle: context.nextUpcomingDeadline,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StatsCard(
            icon: Icons.schedule_rounded,
            value: '${budgetGoalsInsight?.overdueGoals.length ?? 0}',
            label: context.overdueGoals,
            subtitle: context.goalsPastDeadline,
            color: context.primaryColor,
          ),
        ],
      );
}
