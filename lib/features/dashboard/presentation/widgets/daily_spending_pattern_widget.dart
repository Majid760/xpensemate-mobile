import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';

class DailySpendingPatternWidget extends StatefulWidget {
  const DailySpendingPatternWidget({
    super.key,
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  State<DailySpendingPatternWidget> createState() =>
      _DailySpendingPatternWidgetState();
}

class _DailySpendingPatternWidgetState extends State<DailySpendingPatternWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Delay animation slightly
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _animationController.forward();
    });
  }

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
            const _HeaderRow(),
            SizedBox(height: context.md),

            // Bar Chart
            _AnimatedBarChart(
              weeklyStats: widget.weeklyStats,
              animation: _animation,
            ),
          ],
        ),
      );
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            color: context.primaryColor,
            size: 18,
          ),
          SizedBox(width: context.xs),
          Expanded(
            child: Text(
              context.l10n.dailySpendingPattern,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
}

class _AnimatedBarChart extends StatelessWidget {
  const _AnimatedBarChart({
    required this.weeklyStats,
    required this.animation,
  });

  final WeeklyStatsEntity weeklyStats;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => SizedBox(
          height: 120,
          child: _BarChart(
            weeklyStats: weeklyStats,
            animation: animation,
          ),
        ),
      );
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.weeklyStats,
    required this.animation,
  });

  final WeeklyStatsEntity weeklyStats;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final dailyBreakdown = weeklyStats.dailyBreakdown;
    if (dailyBreakdown.isEmpty) {
      return const _EmptyChart();
    }

    // Find max value for scaling
    final maxValue =
        dailyBreakdown.map((day) => day.total).reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) {
      return const _EmptyChart();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: dailyBreakdown.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final percentage = day.total / maxValue;
        final animatedHeight = percentage * animation.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.xs),
            child: _BarColumn(
              day: day,
              index: index,
              animatedHeight: animatedHeight,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.day,
    required this.index,
    required this.animatedHeight,
  });

  final DailyStatsEntity day;
  final int index;
  final double animatedHeight;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          Container(
            height: 80 * animatedHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  context.primaryColor,
                  context.primaryColor.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: context.xs),

          // Day label
          Text(
            _getDayAbbreviation(context, day.date, index),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      );

  String _getDayAbbreviation(BuildContext context, String date, int index) {
    final weekdayAbbreviations = [
      context.l10n.tue,
      context.l10n.wed,
      context.l10n.thu,
      context.l10n.fri,
      context.l10n.sat,
      context.l10n.sun,
      context.l10n.mon,
    ];

    try {
      final dateTime = DateTime.parse(date);
      final weekday = dateTime.weekday;

      // Adjust for different week start (Monday = 1, Sunday = 7)
      final adjustedIndex = (weekday + 5) % 7; // Convert to our array index

      if (adjustedIndex < weekdayAbbreviations.length) {
        return weekdayAbbreviations[adjustedIndex];
      }
    } on Exception catch (_) {
      // Fallback to index-based abbreviation
      if (index < weekdayAbbreviations.length) {
        return weekdayAbbreviations[index];
      }
    }

    return date.substring(0, 3); // Fallback to first 3 characters
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 32,
              color: context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.noSpendingData,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}
