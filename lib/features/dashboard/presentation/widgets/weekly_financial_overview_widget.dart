import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/balance_remaining_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/daily_spending_pattern_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/section_header_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/spending_trend_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/total_expenses_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_insights_widget.dart';

class WeeklyFinancialOverviewWidget extends StatelessWidget {
  const WeeklyFinancialOverviewWidget({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final DashboardState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(context.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SectionHeaderWidget(
                title: context.l10n.weeklyFinancialOverview,
                icon: Icons.calendar_today_rounded,
              ),
              SizedBox(height: context.lg),

              // Content based on state
              if (state.state == DashboardStates.loading)
                const _LoadingStateSection()
              else if (state.state == DashboardStates.error)
                ErrorStateSectionWidget(
                  errorMsg: state.errorMessage,
                  onRetry: onRetry,
                )
              else if (state.state == DashboardStates.loaded &&
                  state.weeklyStats != null)
                _LoadedContentSection(weeklyStats: state.weeklyStats!)
              else
                const _EmptyStateSection(),
            ],
          ),
        ),
      );
}

class _LoadingStateSection extends StatelessWidget {
  const _LoadingStateSection();

  @override
  Widget build(BuildContext context) => Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: context.primaryColor,
              strokeWidth: 3,
            ),
            SizedBox(height: context.md),
            Text(
              context.l10n.loadingDashboardData,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

class _EmptyStateSection extends StatelessWidget {
  const _EmptyStateSection();

  @override
  Widget build(BuildContext context) => Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: context.md),
            Text(
              context.l10n.noDataAvailable,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.startTrackingExpenses,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

class _LoadedContentSection extends StatelessWidget {
  const _LoadedContentSection({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Insights
            WeeklyInsightsWidget(weeklyStats: weeklyStats),
            SizedBox(height: context.lg),

            // Balance and Total Expenses Row
            Row(
              children: [
                Expanded(
                  child: BalanceRemainingWidget(weeklyStats: weeklyStats),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: TotalExpensesWidget(weeklyStats: weeklyStats),
                ),
              ],
            ),
            SizedBox(height: context.lg),

            // Charts Row
            Row(
              children: [
                Expanded(
                  child: DailySpendingPatternWidget(weeklyStats: weeklyStats),
                ),
              ],
            ),
            SizedBox(height: context.lg),

            Row(
              children: [
                Expanded(
                  child: SpendingTrendWidget(weeklyStats: weeklyStats),
                ),
              ],
            ),
          ],
        ),
      );
}
