import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';

class WeeklySummaryCards extends StatefulWidget {
  const WeeklySummaryCards({
    super.key,
    required this.summary,
  });

  final AnalyticsSummaryEntity summary;

  @override
  State<WeeklySummaryCards> createState() => _WeeklySummaryCardsState();
}

class _WeeklySummaryCardsState extends State<WeeklySummaryCards>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
        vsync: this,
      ),
    );

    _slideAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(
            begin: 50,
            end: 0,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            ),
          ),
        )
        .toList();

    _fadeAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOut,
            ),
          ),
        )
        .toList();

    // Start animations with staggered delays
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 500 + (i * 150)), () {
        if (mounted) _animationControllers[i].forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = [
      _SummaryCardData(
        title: 'TOTAL SPENT',
        value: CurrencyFormatter.format(widget.summary.totalSpent),
        icon: Icons.attach_money_rounded,
        iconColor: context.colorScheme.primary,
        backgroundColor:
            context.colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      _SummaryCardData(
        title: 'DAILY\nAVERAGE',
        value: CurrencyFormatter.format(widget.summary.dailyAverage),
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.success,
        backgroundColor: AppColors.successContainer.withValues(alpha: 0.3),
      ),
      _SummaryCardData(
        title: 'HIGHEST DAY',
        value: CurrencyFormatter.format(widget.summary.highestDay),
        icon: Icons.calendar_today_rounded,
        iconColor: AppColors.warning,
        backgroundColor: AppColors.warningContainer.withValues(alpha: 0.3),
      ),
      _SummaryCardData(
        title: 'LOWEST DAY',
        value: CurrencyFormatter.format(widget.summary.lowestDay),
        icon: Icons.show_chart_rounded,
        iconColor: AppColors.info,
        backgroundColor: AppColors.infoContainer.withValues(alpha: 0.3),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout
        final isTablet = constraints.maxWidth > 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final childAspectRatio = isTablet ? 1.2 : 1.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: context.sm,
            mainAxisSpacing: context.sm,
          ),
          itemCount: summaryData.length,
          itemBuilder: (context, index) => AnimatedBuilder(
            animation: _animationControllers[index],
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _slideAnimations[index].value),
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: _SummaryCard(
                  data: summaryData[index],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.data,
  });

  final _SummaryCardData data;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(context.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.icon,
                  color: data.iconColor,
                  size: 24,
                ),
              ),

              SizedBox(height: context.sm),

              // Value
              Text(
                data.value,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.xs),

              // Title
              Text(
                data.title,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}

// Alternative horizontal layout for smaller screens
class WeeklySummaryHorizontalCards extends StatelessWidget {
  const WeeklySummaryHorizontalCards({
    super.key,
    required this.summary,
  });

  final AnalyticsSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final summaryItems = [
      _HorizontalSummaryItem(
        title: 'TOTAL SPENT',
        value: CurrencyFormatter.format(summary.totalSpent),
        icon: Icons.attach_money_rounded,
        iconColor: context.colorScheme.primary,
      ),
      _HorizontalSummaryItem(
        title: 'DAILY AVERAGE',
        value: CurrencyFormatter.format(summary.dailyAverage),
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.success,
      ),
      _HorizontalSummaryItem(
        title: 'HIGHEST DAY',
        value: CurrencyFormatter.format(summary.highestDay),
        icon: Icons.calendar_today_rounded,
        iconColor: AppColors.warning,
      ),
      _HorizontalSummaryItem(
        title: 'LOWEST DAY',
        value: CurrencyFormatter.format(summary.lowestDay),
        icon: Icons.show_chart_rounded,
        iconColor: AppColors.info,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: context.sm),
      child: Row(
        children: summaryItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index < summaryItems.length - 1 ? context.xs : 0,
            ),
            child: _HorizontalSummaryCard(item: item),
          );
        }).toList(),
      ),
    );
  }
}

class _HorizontalSummaryItem {
  const _HorizontalSummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
}

class _HorizontalSummaryCard extends StatelessWidget {
  const _HorizontalSummaryCard({
    required this.item,
  });

  final _HorizontalSummaryItem item;

  @override
  Widget build(BuildContext context) => Container(
        width: 140,
        padding: EdgeInsets.all(context.sm),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: item.iconColor,
              size: 18,
            ),
            SizedBox(height: context.xs),
            Text(
              item.value,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.title,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      );
}
