import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';

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
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.onPrimary
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(
                                    ThemeConstants.radiusMedium,
                                  ),
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: AppSpacing.iconSm,
                                  color: context.colorScheme.onPrimary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.value,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.95),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            widget.label.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.95),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
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
                                    .onPrimary
                                    .withValues(alpha: 0.8),
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

class _ExpandableTextState extends State<_ExpandableText>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  Timer? _collapseTimer;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _animationController.forward().then((_) {
          setState(() {
            _isExpanded = false;
          });
          _animationController.reverse();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });

          if (_isExpanded) {
            _startCollapseTimer();
          } else {
            _collapseTimer?.cancel();
          }
        },
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Text(
            widget.text,
            maxLines: _isExpanded ? null : 1,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
            style: widget.style,
          ),
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
