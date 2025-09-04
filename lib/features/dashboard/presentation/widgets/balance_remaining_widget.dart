import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';

class BalanceRemainingWidget extends StatefulWidget {
  const BalanceRemainingWidget({
    super.key,
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  State<BalanceRemainingWidget> createState() => _BalanceRemainingWidgetState();
}

class _BalanceRemainingWidgetState extends State<BalanceRemainingWidget>
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

    _animationController.forward();
  }

  double _calculateProgressPercentage() {
    // Match web implementation:
    // percentage = max > 0 ? Math.min((Math.abs(value) / max) * 100, 100) : 0

    // If weeklyBudget is 0 or negative, show no progress
    if (widget.weeklyStats.weeklyBudget <= 0) {
      return 0;
    }

    // Calculate percentage based on absolute value of balanceLeft, capped at 100%
    // This matches the web implementation
    final absBalanceLeft = widget.weeklyStats.balanceLeft.abs();
    return (absBalanceLeft / widget.weeklyStats.weeklyBudget).clamp(0.0, 1.0);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is _CircularProgressPainter &&
      oldDelegate.progress != progress;
}

class _CircularProgressIndicator extends StatelessWidget {
  const _CircularProgressIndicator({
    required this.progressAnimation,
    required this.weeklyStats,
  });

  final Animation<double> progressAnimation;
  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 120,
        height: 120,
        child: AnimatedBuilder(
          animation: progressAnimation,
          builder: (context, child) => CustomPaint(
            painter: _CircularProgressPainter(
              progress: progressAnimation.value,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              progressColor: weeklyStats.balanceLeft < 0
                  ? context.colorScheme.error
                  : context.colorScheme.primary,
              strokeWidth: 8,
            ),
            child: Center(
              child: _CircularProgressContent(
                progressAnimation: progressAnimation,
                weeklyStats: weeklyStats,
              ),
            ),
          ),
        ),
      );
}

class _CircularProgressContent extends StatelessWidget {
  const _CircularProgressContent({
    required this.progressAnimation,
    required this.weeklyStats,
  });

  final Animation<double> progressAnimation;
  final WeeklyStatsEntity weeklyStats;

  String _calculatePercentageText(
    double progressValue,
    WeeklyStatsEntity stats,
  ) {
    // Match web implementation: percentage display calculation
    // If we have a budget, calculate absolute percentage
    if (stats.weeklyBudget > 0) {
      final absPercentage =
          ((stats.balanceLeft.abs() / stats.weeklyBudget) * 100)
              .clamp(0.0, 100.0);
      return '${absPercentage.round()}%';
    }

    // If no budget, return 0%
    return '0%';
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: weeklyStats.balanceLeft < 0
                ? context.colorScheme.error
                : context.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: context.xs),
          Text(
            CurrencyFormatter.format(weeklyStats.balanceLeft),
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            _calculatePercentageText(progressAnimation.value, weeklyStats),
            style: context.textTheme.bodySmall?.copyWith(
              color: weeklyStats.balanceLeft < 0
                  ? context.colorScheme.error
                  : context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _TitleAndSubtitleSection extends StatelessWidget {
  const _TitleAndSubtitleSection({
    required this.weeklyStats,
  });

  final WeeklyStatsEntity weeklyStats;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            context.l10n.balanceRemaining,
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
            '${context.l10n.of12} ${CurrencyFormatter.format(weeklyStats.weeklyBudget)} ${context.l10n.budget}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      );
}
