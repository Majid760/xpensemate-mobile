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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          if (isTablet) {
            return _TabletInsightsLayout(weeklyStats: weeklyStats);
          } else {
            return _MobileInsightsLayout(weeklyStats: weeklyStats);
          }
        },
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
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _HighestDayCard(weeklyStats: weeklyStats),
          ),
          SizedBox(width: context.sm),
          Expanded(
            child: _LowestDayCard(weeklyStats: weeklyStats),
          ),
          SizedBox(width: context.sm),
          Expanded(
            child: _DailyAverageCard(weeklyStats: weeklyStats),
          ),
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
        amount: "\$${weeklyStats.highestDay.total.toStringAsFixed(0)}",
        subtitle: _formatDayName(context, weeklyStats.highestDay.date),
        backgroundColor: context.colorScheme.surface,
        borderColor: Colors.transparent,
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
        iconColor: AppColors.danger,
        title: context.l10n.lowestDay,
        amount: "\$${weeklyStats.lowestDay.total.toStringAsFixed(0)}",
        subtitle: _formatDayName(context, weeklyStats.lowestDay.date),
        backgroundColor: context.colorScheme.surface,
        borderColor: Colors.transparent,
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
        icon: Icons.attach_money,
        iconColor: AppColors.info,
        title: context.l10n.dailyAverage,
        amount: "\$${weeklyStats.dailyAverage.toStringAsFixed(2)}",
        subtitle: context.l10n.acrossSevenDays,
        backgroundColor: context.colorScheme.surface,
        borderColor: Colors.transparent,
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
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                SizedBox(width: context.xs),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.md),
            Text(
              amount,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: context.md),
            Text(
              subtitle,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      );
}
