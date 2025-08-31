import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';

class WeeklyInsightsWidget extends StatelessWidget {
  const WeeklyInsightsWidget({
    super.key,
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.weeklyInsights,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              if (isTablet) {
                return _TabletInsightsLayout(weeklyStats: weeklyStats);
              } else {
                return _MobileInsightsLayout(weeklyStats: weeklyStats);
              }
            },
          ),
        ],
      );
}

class _TabletInsightsLayout extends StatelessWidget {
  const _TabletInsightsLayout({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _HighestDayCard(weeklyStats: weeklyStats),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: _LowestDayCard(weeklyStats: weeklyStats),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: _DailyAverageCard(weeklyStats: weeklyStats),
          ),
        ],
      );
}

class _MobileInsightsLayout extends StatelessWidget {
  const _MobileInsightsLayout({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _HighestDayCard(weeklyStats: weeklyStats),
              ),
              SizedBox(width: context.sm),
              Expanded(
                child: _LowestDayCard(weeklyStats: weeklyStats),
              ),
            ],
          ),
          SizedBox(height: context.sm),
          _DailyAverageCard(weeklyStats: weeklyStats),
        ],
      );
}

class _HighestDayCard extends StatelessWidget {
  const _HighestDayCard({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => _InsightCard(
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.success,
        title: context.l10n.highestDay,
        amount: CurrencyFormatter.format(weeklyStats.highestDay.total),
        subtitle: _formatDayName(context, weeklyStats.highestDay.date),
        backgroundColor: AppColors.success.withValues(alpha: 0.08),
        borderColor: AppColors.success.withValues(alpha: 0.15),
      );

  String _formatDayName(BuildContext context, String date) {
    try {
      final dateTime = DateTime.parse(date);
      final weekdays = [
        context.l10n.monday,
        context.l10n.tuesday,
        context.l10n.wednesday,
        context.l10n.thursday,
        context.l10n.friday,
        context.l10n.saturday,
        context.l10n.sunday,
      ];
      return '${weekdays[dateTime.weekday - 1]}';
    } on Exception catch (_) {
      return '$date';
    }
  }
}

class _LowestDayCard extends StatelessWidget {
  const _LowestDayCard({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => _InsightCard(
        icon: Icons.trending_down_rounded,
        iconColor: AppColors.warning,
        title: context.l10n.lowestDay,
        amount: CurrencyFormatter.format(weeklyStats.lowestDay.total),
        subtitle: _formatDayName(context, weeklyStats.lowestDay.date),
        backgroundColor: AppColors.warning.withValues(alpha: 0.08),
        borderColor: AppColors.warning.withValues(alpha: 0.15),
      );

  String _formatDayName(BuildContext context, String date) {
    try {
      final dateTime = DateTime.parse(date);
      final weekdays = [
        context.l10n.monday,
        context.l10n.tuesday,
        context.l10n.wednesday,
        context.l10n.thursday,
        context.l10n.friday,
        context.l10n.saturday,
        context.l10n.sunday,
      ];
      return '${weekdays[dateTime.weekday - 1]}';
    } on Exception catch (_) {
      return '$date';
    }
  }
}

class _DailyAverageCard extends StatelessWidget {
  const _DailyAverageCard({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => _InsightCard(
        icon: Icons.analytics_outlined,
        iconColor: AppColors.info,
        title: context.l10n.dailyAverage,
        amount: CurrencyFormatter.format(weeklyStats.dailyAverage),
        subtitle: context.l10n.acrossSevenDays,
        backgroundColor: AppColors.info.withValues(alpha: 0.08),
        borderColor: AppColors.info.withValues(alpha: 0.15),
        isFullWidth: true,
      );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    this.isFullWidth = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) => Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.all(context.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
                SizedBox(width: context.xs),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sm),
            Text(
              amount,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: context.xs),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      );
}
