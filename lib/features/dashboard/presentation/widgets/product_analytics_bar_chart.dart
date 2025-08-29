import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';

class ProductAnalyticsBarChart extends StatefulWidget {
  const ProductAnalyticsBarChart({
    super.key,
    required this.productAnalytics,
    this.height = 300,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  final ProductWeeklyAnalyticsEntity productAnalytics;
  final double height;
  final Duration animationDuration;

  @override
  State<ProductAnalyticsBarChart> createState() =>
      _ProductAnalyticsBarChartState();
}

class _ProductAnalyticsBarChartState extends State<ProductAnalyticsBarChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animationValue;
  late List<String> _weekDays;
  late double _maxValue;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(ProductAnalyticsBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the analytics data has actually changed (not just reference)
    if (oldWidget.productAnalytics.currentCategory !=
            widget.productAnalytics.currentCategory ||
        oldWidget.productAnalytics.days.length !=
            widget.productAnalytics.days.length ||
        oldWidget.productAnalytics.hashCode !=
            widget.productAnalytics.hashCode) {
      _initializeData();
      // Only restart animation if we're not already animating
      if (_animationController.isCompleted) {
        _animationController.reset();
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _animationController.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Get the days from the analytics data with safe date parsing
    _weekDays = widget.productAnalytics.days.map((day) {
      try {
        final date = DateTime.parse(day.date);
        return _getShortDayName(date.weekday);
      } on Exception catch (_) {
        // If date parsing fails, use a default or the date string
        return day.date.isNotEmpty ? day.date.substring(0, 3) : 'Day';
      }
    }).toList();

    // Find maximum value for scaling
    final values =
        widget.productAnalytics.days.map((day) => day.total).toList();
    if (values.isEmpty) {
      _maxValue = 100.0; // Default value if no data
    } else {
      _maxValue = values.reduce(math.max);
      // Ensure minimum scale for better visualization
      if (_maxValue <= 0) _maxValue = 100.0;
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animationValue = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _animationController.forward();
    });
  }

  String _getShortDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    final index = value.toInt();
    if (index >= 0 && index < _weekDays.length) {
      return SideTitleWidget(
        meta: meta,
        child: Text(
          _weekDays[index],
          style: style.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '\$${value.toInt()}',
        style: style.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  BarChartData _buildBarChartData() => BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: _maxValue * 1.15,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) =>
                Theme.of(context).colorScheme.inverseSurface,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY;
              final day = _weekDays.isNotEmpty && groupIndex < _weekDays.length
                  ? _weekDays[groupIndex]
                  : 'Day ${groupIndex + 1}';
              return BarTooltipItem(
                '$day\n${CurrencyFormatter.format(value)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: _bottomTitles,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: _leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          checkToShowHorizontalLine: (value) =>
              value % (_maxValue / 4).round() == 0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        groupsSpace: 16,
        barGroups: _buildBarGroups(),
      );

  List<BarChartGroupData> _buildBarGroups() =>
      widget.productAnalytics.days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final animatedValue = day.total * _animationValue.value;

        // Calculate responsive bar width based on available space
        const baseWidth = 16.0; // Thinner bars
        final constraints = MediaQuery.of(context).size;
        final barsWidth = baseWidth * constraints.width / 400;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: animatedValue,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              width:
                  barsWidth.clamp(12.0, 20.0), // Ensure reasonable width range
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _maxValue * 1.15,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withValues(alpha: 0.2),
              ),
            ),
          ],
        );
      }).toList();

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1.8,
        child: Padding(
          padding: EdgeInsets.all(context.md),
          child: AnimatedBuilder(
            animation: _animationValue,
            builder: (context, child) => BarChart(
              _buildBarChartData(),
              duration: widget.animationDuration,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
}
