import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/balance_remaining_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/daily_spending_pattern_widget.dart';
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
        padding: EdgeInsets.all(context.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _HeaderSection(
              onRetry: onRetry,
            ),
            SizedBox(height: context.lg),
            
            // Content based on state
            if (state.state == DashboardStates.loading)
              _LoadingStateSection()
            else if (state.state == DashboardStates.error)
              _ErrorStateSection(
                state: state,
                onRetry: onRetry,
              )
            else if (state.state == DashboardStates.loaded && state.weeklyStats != null)
              _LoadedContentSection(weeklyStats: state.weeklyStats!)
            else
              _EmptyStateSection(),
          ],
        ),
      ),
    );
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        SizedBox(width: context.md),
        Expanded(
          child: Text(
            context.l10n.weeklyFinancialOverview,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _LoadingStateSection extends StatelessWidget {
  const _LoadingStateSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
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
}

class _ErrorStateSection extends StatelessWidget {
  const _ErrorStateSection({
    required this.state,
    required this.onRetry,
  });

  final DashboardState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: context.colorScheme.error,
          ),
          SizedBox(height: context.md),
          Text(
            context.l10n.failedToLoadData,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.sm),
          Text(
            state.errorMessage ?? context.l10n.unknownError,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.lg),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.tryAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateSection extends StatelessWidget {
  const _EmptyStateSection();

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _LoadedContentSection extends StatelessWidget {
  const _LoadedContentSection({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        if (isTablet) {
          return _TabletLayout(weeklyStats: weeklyStats);
        } else {
          return _MobileLayout(weeklyStats: weeklyStats);
        }
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            SizedBox(width: context.md),
            Expanded(
              child: SpendingTrendWidget(weeklyStats: weeklyStats),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Insights
        WeeklyInsightsWidget(weeklyStats: weeklyStats),
        SizedBox(height: context.lg),
        
        // Main content in two columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Charts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DailySpendingPatternWidget(weeklyStats: weeklyStats),
                      ),
                      SizedBox(width: context.md),
                      Expanded(
                        child: SpendingTrendWidget(weeklyStats: weeklyStats),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: context.lg),
            
            // Right column - Circular indicators
            Expanded(
              child: Column(
                children: [
                  BalanceRemainingWidget(weeklyStats: weeklyStats),
                  SizedBox(height: context.md),
                  TotalExpensesWidget(weeklyStats: weeklyStats),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}