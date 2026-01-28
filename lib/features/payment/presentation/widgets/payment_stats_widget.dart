import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';

class PaymentStatsWidget extends StatefulWidget {
  const PaymentStatsWidget({
    super.key,
    required this.stats,
    required this.defaultPeriod,
  });
  final PaymentStatsEntity? stats;
  final FilterValue defaultPeriod;

  @override
  State<PaymentStatsWidget> createState() => _PaymentStatsWidgetState();
}

class _PaymentStatsWidgetState extends State<PaymentStatsWidget>
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
    HapticFeedback.lightImpact();
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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primary,
              context.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          child: Material(
            color: context.colorScheme.primary,
            child: InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.overview,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.onPrimaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${widget.defaultPeriod.name.capitalize} ${context.l10n.insights}',
                              style: context.textTheme.headlineSmall?.copyWith(
                                color: context.onPrimaryColor,
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
                            padding: EdgeInsets.all(context.sm),
                            decoration: BoxDecoration(
                              color:
                                  context.onPrimaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.onPrimaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md1),
                    // Quick Stats Row (Abstract - Always Visible)
                    _QuickStatsRow(stats: widget.stats),
                    // Expandable Detailed Section
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1,
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.md1),
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
                          const SizedBox(height: AppSpacing.md1),
                          _DetailedStatsGrid(stats: widget.stats),
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

// Quick Stats Row - Abstract view (collapsed state)
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});
  final PaymentStatsEntity? stats;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.account_balance_wallet_rounded,
              value: AppUtils.formatLargeNumber(stats?.walletBalance ?? 0),
              label: context.l10n.walletBalance,
              iconBg: context.onPrimaryColor.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.onPrimaryColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.trending_up_rounded,
              value: '${(stats?.periodGrowth ?? 0).toStringAsFixed(1)}%',
              label: context.l10n.growth,
              iconBg: context.onPrimaryColor.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.onPrimaryColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.person_rounded,
              value: stats?.topPayer ?? 'N/A',
              label: context.l10n.topPayer,
              iconBg: context.onPrimaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
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
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppSpacing.sm1),
            ),
            child: Icon(
              icon,
              color: context.onPrimaryColor,
              size: AppSpacing.iconMd,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.onPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.onPrimaryColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
}

// Detailed Stats Grid - Detailed view (expanded state)
class _DetailedStatsGrid extends StatelessWidget {
  const _DetailedStatsGrid({required this.stats});
  final PaymentStatsEntity? stats;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  icon: Icons.account_balance_wallet_rounded,
                  value: AppUtils.formatLargeNumber(stats?.totalAmount ?? 0),
                  label: context.l10n.totalBalance,
                  subtitle: context.l10n.walletBalance,
                ),
              ),
              const SizedBox(width: AppSpacing.sm1),
              Expanded(
                child: _StatsCard(
                  icon: Icons.analytics_rounded,
                  value: AppUtils.formatLargeNumber(stats?.averagePayment ?? 0),
                  label: context.l10n.averagePayment,
                  subtitle: context.l10n.perTransaction,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm1),
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  icon: Icons.trending_up_rounded,
                  value: '+${(stats?.periodGrowth ?? 0).toStringAsFixed(1)}%',
                  label: context.l10n.growthWeekly,
                  subtitle: context.l10n.increaseFromPreviousPeriod,
                ),
              ),
              const SizedBox(width: AppSpacing.sm1),
              Expanded(
                child: _StatsCard(
                  icon: Icons.person_rounded,
                  value: stats?.topPayer ?? 'N/A',
                  label: context.l10n.topPayer,
                  subtitle:
                      CurrencyFormatter.format(stats?.topPayerAmount ?? 0),
                ),
              ),
            ],
          ),
        ],
      );
}

class _StatsCard extends StatefulWidget {
  const _StatsCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String value;
  final String label;
  final String subtitle;

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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
    _controller.forward();
  }

  void _handleHoverExit(PointerEvent event) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: _handleHoverEnter,
        onExit: _handleHoverExit,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _isHovered ? _translateAnimation.value : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(AppSpacing.sm1),
              decoration: BoxDecoration(
                color: context.onPrimaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(
                  color: context.onPrimaryColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.onPrimaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        child: Icon(
                          widget.icon,
                          size: AppSpacing.iconSm,
                          color: context.onPrimaryColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.value,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            color:
                                context.onPrimaryColor.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm1),
                  Text(
                    widget.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onPrimary.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.subtitle,
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onPrimary.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
