import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
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
    if (oldWidget.productAnalytics.currentCategory !=
            widget.productAnalytics.currentCategory ||
        oldWidget.productAnalytics.days.length !=
            widget.productAnalytics.days.length ||
        oldWidget.productAnalytics.hashCode !=
            widget.productAnalytics.hashCode) {
      _initializeData();
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
    _weekDays = widget.productAnalytics.days.map((day) {
      try {
        final date = DateTime.parse(day.date);
        return _getShortDayName(date.weekday);
      } on Exception catch (_) {
        return day.date.isNotEmpty
            ? day.date.substring(0, math.min(3, day.date.length))
            : context.l10n.day;
      }
    }).toList();

    final values =
        widget.productAnalytics.days.map((day) => day.total).toList();
    if (values.isEmpty) {
      _maxValue = 100.0;
    } else {
      _maxValue = values.reduce(math.max);
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
            color: context.colorScheme.onSurfaceVariant,
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
          color: context.colorScheme.onSurfaceVariant,
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
            getTooltipColor: (group) => context.colorScheme.inverseSurface,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY;
              final day = _weekDays.isNotEmpty && groupIndex < _weekDays.length
                  ? _weekDays[groupIndex]
                  : '${context.l10n.day} ${groupIndex + 1}';
              return BarTooltipItem(
                '$day\n${CurrencyFormatter.format(value)}',
                TextStyle(
                  color: context.colorScheme.onInverseSurface,
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
            color: context.colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        groupsSpace: 16,
        barGroups: _buildBarGroups(),
      );

  List<BarChartGroupData> _buildBarGroups() {
    final days = widget.productAnalytics.days;
    // Handle empty data gracefully
    if (days.isEmpty) {
      // EMERGENCY FIX: If days is empty but allCategoryData has data, try using that
      if (widget.productAnalytics.allCategoryData.isNotEmpty) {
        final firstCategory =
            widget.productAnalytics.allCategoryData.keys.first;
        final backupData =
            widget.productAnalytics.allCategoryData[firstCategory];

        if (backupData != null && backupData.isNotEmpty) {
          return backupData.asMap().entries.map((entry) {
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
                  width: barsWidth.clamp(
                    12.0,
                    20.0,
                  ), // Ensure reasonable width range
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: _maxValue * 1.15,
                    color: context.colorScheme.surfaceContainerHigh
                        .withValues(alpha: 0.2),
                  ),
                ),
              ],
            );
          }).toList();
        }
      }

      return [];
    }

    return days.asMap().entries.map((entry) {
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
            width: barsWidth.clamp(12.0, 20.0), // Ensure reasonable width range
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxValue * 1.15,
              color: context.colorScheme.surfaceContainerHigh
                  .withValues(alpha: 0.2),
            ),
          ),
        ],
      );
    }).toList();
  }

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
