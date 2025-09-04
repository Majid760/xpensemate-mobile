import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';

class SpendingTrendWidget extends StatefulWidget {
  const SpendingTrendWidget({
    super.key,
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  State<SpendingTrendWidget> createState() => _SpendingTrendWidgetState();
}

class _SpendingTrendWidgetState extends State<SpendingTrendWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredIndex;

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Delay animation
    Future.delayed(const Duration(milliseconds: 600), () {
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
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: context.secondaryColor,
                  size: 18,
                ),
                SizedBox(width: context.xs),
                Expanded(
                  child: Text(
                    context.l10n.spendingTrend,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.md),

            // Line Chart
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => SizedBox(
                height: 120,
                child: _LineChart(
                  weeklyStats: widget.weeklyStats,
                  animation: _animation,
                  onHoverIndexChanged: (index) =>
                      setState(() => _hoveredIndex = index),
                  hoveredIndex: _hoveredIndex,
                ),
              ),
            ),
          ],
        ),
      );
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.weeklyStats,
    required this.animation,
    required this.onHoverIndexChanged,
    required this.hoveredIndex,
  });

  final WeeklyStatsEntity weeklyStats;
  final Animation<double> animation;
  final ValueChanged<int?> onHoverIndexChanged;
  final int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final dailyBreakdown = weeklyStats.dailyBreakdown;
    if (dailyBreakdown.isEmpty) {
      return _EmptyChart(weeklyStats: weeklyStats);
    }

    // Calculate cumulative values
    final cumulativeData = <double>[];
    double cumulative = 0;
    for (final day in dailyBreakdown) {
      cumulative += day.total;
      cumulativeData.add(cumulative);
    }

    final maxValue = cumulativeData.isNotEmpty ? cumulativeData.last : 0.0;
    if (maxValue <= 0) {
      return _EmptyChart(weeklyStats: weeklyStats);
    }

    return Stack(
      children: [
        // Line Chart
        CustomPaint(
          size: const Size(double.infinity, 120),
          painter: _LineChartPainter(
            data: cumulativeData,
            maxValue: maxValue,
            animation: animation,
            primaryColor: context.secondaryColor,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
          ),
        ),

        // Interactive overlay for tooltip
        Positioned.fill(
          child: _InteractiveOverlay(
            cumulativeData: cumulativeData,
            onHoverIndexChanged: onHoverIndexChanged,
            hoveredIndex: hoveredIndex,
            weeklyStats: weeklyStats,
          ),
        ),

        // Day labels
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _DayLabels(weeklyStats: weeklyStats),
        ),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 32,
              color: context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.noTrendData,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

class _InteractiveOverlay extends StatelessWidget {
  const _InteractiveOverlay({
    required this.cumulativeData,
    required this.onHoverIndexChanged,
    required this.hoveredIndex,
    required this.weeklyStats,
  });

  final List<double> cumulativeData;
  final ValueChanged<int?> onHoverIndexChanged;
  final int? hoveredIndex;
  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (details) => _handleTap(context, details, cumulativeData),
        onPanUpdate: (details) => _handlePan(context, details, cumulativeData),
        onPanEnd: (_) => onHoverIndexChanged(null),
        child: ColoredBox(
          color: Colors.transparent,
          child: hoveredIndex != null
              ? _ChartTooltip(
                  hoveredIndex: hoveredIndex!,
                  cumulativeData: cumulativeData,
                  weeklyStats: weeklyStats,
                )
              : null,
        ),
      );

  void _handleTap(
      BuildContext context, TapDownDetails details, List<double> data) {
    final renderBox = context.findRenderObject();
    if (renderBox is RenderBox) {
      final localPosition = details.localPosition;
      final index =
          _getIndexFromPosition(localPosition, renderBox.size, data.length);
      onHoverIndexChanged(index);
    }
  }

  void _handlePan(
      BuildContext context, DragUpdateDetails details, List<double> data) {
    final renderBox = context.findRenderObject();
    if (renderBox is RenderBox) {
      final localPosition = details.localPosition;
      final index =
          _getIndexFromPosition(localPosition, renderBox.size, data.length);
      onHoverIndexChanged(index);
    }
  }

  int? _getIndexFromPosition(Offset position, Size size, int dataLength) {
    if (dataLength == 0) return null;

    final relativeX = position.dx / size.width;
    final index = (relativeX * dataLength).round().clamp(0, dataLength - 1);
    return index;
  }
}

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({
    required this.hoveredIndex,
    required this.cumulativeData,
    required this.weeklyStats,
  });

  final int hoveredIndex;
  final List<double> cumulativeData;
  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    if (hoveredIndex >= cumulativeData.length) {
      return const SizedBox.shrink();
    }

    final value = cumulativeData[hoveredIndex];
    final dailyBreakdown = weeklyStats.dailyBreakdown;
    final day = dailyBreakdown[hoveredIndex];

    return Positioned(
      top: 10,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sm,
          vertical: context.xs,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getDayName(context, day.date, hoveredIndex),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onInverseSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${context.l10n.cumulative}: ${CurrencyFormatter.format(value)}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(BuildContext context, String date, int index) {
    final weekdays = [
      context.l10n.wednesday,
      context.l10n.thursday,
      context.l10n.friday,
      context.l10n.saturday,
      context.l10n.sunday,
      context.l10n.monday,
      context.l10n.tuesday,
    ];

    if (index < weekdays.length) {
      return weekdays[index];
    }
    return date;
  }
}

class _DayLabels extends StatelessWidget {
  const _DayLabels({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    final dailyBreakdown = weeklyStats.dailyBreakdown;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: dailyBreakdown.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        return Text(
          _getDayAbbreviation(context, day.date, index),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        );
      }).toList(),
    );
  }

  String _getDayAbbreviation(BuildContext context, String date, int index) {
    final weekdayAbbreviations = [
      context.l10n.wed,
      context.l10n.thu,
      context.l10n.fri,
      context.l10n.sat,
      context.l10n.sun,
      context.l10n.mon,
      context.l10n.tue,
    ];

    if (index < weekdayAbbreviations.length) {
      return weekdayAbbreviations[index];
    }
    return date.substring(0, 3);
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.animation,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final List<double> data;
  final double maxValue;
  final Animation<double> animation;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue <= 0) return;

    final chartHeight = size.height - 20; // Leave space for labels
    final stepX = size.width / (data.length - 1);

    // Create path for line
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = chartHeight - (data[i] / maxValue * chartHeight);
      final animatedY = chartHeight - ((chartHeight - y) * animation.value);

      points.add(Offset(x, animatedY));

      if (i == 0) {
        path.moveTo(x, animatedY);
      } else {
        path.lineTo(x, animatedY);
      }
    }

    // Draw line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
        point,
        3,
        Paint()..color = backgroundColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is _LineChartPainter &&
      oldDelegate.animation.value != animation.value;
}
