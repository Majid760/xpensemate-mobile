import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';

class TotalExpensesWidget extends StatefulWidget {
  const TotalExpensesWidget({
    super.key,
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  State<TotalExpensesWidget> createState() => _TotalExpensesWidgetState();
}

class _TotalExpensesWidgetState extends State<TotalExpensesWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

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

    final progressPercentage = _calculateProgressPercentage();
    _progressAnimation = Tween<double>(
      begin: 0,
      end: progressPercentage,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Delay the animation slightly after balance remaining
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _animationController.forward();
    });
  }

  double _calculateProgressPercentage() {
    if (widget.weeklyStats.weeklyBudget <= 0) return 0;
    return (widget.weeklyStats.weekTotal / widget.weeklyStats.weeklyBudget)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.lg),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
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
        children: [
          // Circular Progress
          _CircularProgressIndicator(
            progressAnimation: _progressAnimation,
            weeklyStats: widget.weeklyStats,
          ),
          SizedBox(height: context.md),
          
          // Title and Subtitle
          _TitleAndSubtitleSection(
            weeklyStats: widget.weeklyStats,
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            progressColor,
            progressColor.withValues(alpha: 0.8),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CircularProgressPainter &&
        oldDelegate.progress != progress;
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  const _CircularProgressIndicator({
    required this.progressAnimation,
    required this.weeklyStats,
  });

  final Animation<double> progressAnimation;
  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: progressAnimation.value,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              progressColor: AppColors.primary,
              strokeWidth: 8,
            ),
            child: Center(
              child: _CircularProgressContent(
                progressAnimation: progressAnimation,
                weeklyStats: weeklyStats,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressContent extends StatelessWidget {
  const _CircularProgressContent({
    required this.progressAnimation,
    required this.weeklyStats,
  });

  final Animation<double> progressAnimation;
  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          color: AppColors.primary,
          size: 24,
        ),
        SizedBox(height: context.xs),
        Text(
          CurrencyFormatter.format(weeklyStats.weekTotal),
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          '${(progressAnimation.value * 100).round()}%',
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TitleAndSubtitleSection extends StatelessWidget {
  const _TitleAndSubtitleSection({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.totalExpenses,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: context.xs),
        Text(
          context.l10n.thisWeek,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}