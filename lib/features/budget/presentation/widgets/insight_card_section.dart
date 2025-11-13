import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';

class ExpandableStatsCard extends StatefulWidget {
  const ExpandableStatsCard({super.key, this.budgetGoalsInsight});
  final BudgetGoalsInsightEntity? budgetGoalsInsight;

  @override
  State<ExpandableStatsCard> createState() => _ExpandableStatsCardState();
}

class _ExpandableStatsCardState extends State<ExpandableStatsCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.tertiary,
            ],
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.overview,
                              style: (context.textTheme.titleMedium ??
                                      const TextStyle())
                                  .copyWith(
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.budgetStatistics,
                              style: (context.textTheme.headlineSmall ??
                                      const TextStyle())
                                  .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.radiusMedium,
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: AppSpacing.iconLg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    QuickStatsRow(
                      budgetGoalsInsight: widget.budgetGoalsInsight,
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1,
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          DetailedStatsGrid(
                            budgetGoalsInsight: widget.budgetGoalsInsight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class DetailedStatsGrid extends StatelessWidget {
  const DetailedStatsGrid({super.key, this.budgetGoalsInsight});
  final BudgetGoalsInsightEntity? budgetGoalsInsight;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  icon: Icons.cancel_outlined,
                  value:
                      '${budgetGoalsInsight?.failedGoals.length ?? 0}/${budgetGoalsInsight?.terminatedGoals.length ?? 0}',
                  label: context.failedTerminated,
                  subtitle: context.goalsNotCompleted,
                  color: context.theme.primaryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsCard(
                  icon: Icons.attach_money_rounded,
                  value:
                      '\$${budgetGoalsInsight?.totalBudgeted.toStringAsFixed(1) ?? '0.0'}',
                  label: context.totalBudgeted,
                  subtitle: context.totalAmountAllocated,
                  color: context.theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  icon: Icons.analytics_outlined,
                  value:
                      '${budgetGoalsInsight?.avgProgress.toStringAsFixed(1) ?? '0.0'}%',
                  label: context.avgProgress,
                  subtitle: context.averageProgressGoals,
                  color: context.theme.primaryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsCard(
                  icon: Icons.event_outlined,
                  value: budgetGoalsInsight?.closestDeadlineDate ??
                      context.noDeadlines,
                  label: context.closestDeadline,
                  subtitle: context.nextUpcomingDeadline,
                  color: context.theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StatsCard(
            icon: Icons.schedule_rounded,
            value: '${budgetGoalsInsight?.overdueGoals.length ?? 0}',
            label: context.overdueGoals,
            subtitle: context.goalsPastDeadline,
            color: context.theme.primaryColor,
          ),
        ],
      );
}

class StatsCard extends StatefulWidget {
  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.textColor,
    this.loading = false,
    this.clickable = false,
    this.onClick,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final Color? textColor;
  final bool loading;
  final bool clickable;
  final VoidCallback? onClick;

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _translateAnimation = Tween<double>(begin: 0, end: -2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEvent event) {
    setState(() => _isHovered = true);
    if (!_isPressed) {
      _controller.forward();
    }
  }

  void _handleHoverExit(PointerEvent event) {
    setState(() => _isHovered = false);
    if (!_isPressed) {
      _controller.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.clickable) {
      setState(() => _isPressed = true);
      _controller.reverse();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.clickable) {
      setState(() => _isPressed = false);
      if (_isHovered) {
        _controller.forward();
      }
      widget.onClick?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.clickable) {
      setState(() => _isPressed = false);
      if (_isHovered) {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: _handleHoverEnter,
        onExit: _handleHoverExit,
        cursor: widget.clickable
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                0,
                _isHovered && !_isPressed ? _translateAnimation.value : 0,
              ),
              child: Transform.scale(
                scale: _isPressed && widget.clickable
                    ? _scaleAnimation.value
                    : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: _isHovered
                          ? widget.color.withValues(alpha: 1)
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.radiusLarge),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon and Label Row
                          Row(
                            children: [
                              // Icon Container
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    ThemeConstants.radiusMedium,
                                  ),
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: AppSpacing.iconMd,
                                  color: widget.color,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              // Label
                              Expanded(
                                child: Text(
                                  widget.label.toUpperCase(),
                                  style: (context.textTheme.labelMedium ??
                                          const TextStyle())
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Value
                          if (widget.loading)
                            Container(
                              width: 48,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _PulsingShimmer(),
                            )
                          else
                            Text(
                              widget.value,
                              style: (context.textTheme.headlineSmall ??
                                      const TextStyle())
                                  .copyWith(
                                color: widget.textColor ??
                                    Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                          // Subtitle
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            _ExpandableText(
                              text: widget.subtitle!,
                              style: (context.textTheme.bodySmall ??
                                      const TextStyle())
                                  .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

// Shimmer animation for loading state
class _PulsingShimmer extends StatefulWidget {
  @override
  State<_PulsingShimmer> createState() => _PulsingShimmerState();
}

class _PulsingShimmerState extends State<_PulsingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Opacity(
          opacity: _animation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
}

// Expandable text widget that shows full text when clicked
class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Text(
          widget.text,
          maxLines: _isExpanded ? null : 1,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
          style: widget.style,
        ),
      );
}

class _QuickStatItem extends StatelessWidget {
  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm1),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
            ),
            child: Icon(icon, color: Colors.white, size: AppSpacing.iconLg),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style:
                (context.textTheme.headlineSmall ?? const TextStyle()).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: (context.textTheme.bodySmall ?? const TextStyle()).copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
}

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key, this.budgetGoalsInsight});
  final BudgetGoalsInsightEntity? budgetGoalsInsight;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.emoji_events_outlined,
              value: budgetGoalsInsight?.totalGoals.toString() ?? '0',
              label: context.totalGoals,
              iconBg: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.trending_up_rounded,
              value: budgetGoalsInsight?.activeGoals.length.toString() ?? '0',
              label: context.active,
              iconBg: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.check_circle_outline,
              value: budgetGoalsInsight?.achievedGoals.length.toString() ?? '0',
              label: context.achieved,
              iconBg: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      );
}
