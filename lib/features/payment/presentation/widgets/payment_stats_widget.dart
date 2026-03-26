import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/core/widget/stat_widget.dart';
import 'package:xpensemate/features/budget/presentation/widgets/stat_card.dart';
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
                            SizedBox(height: context.lg),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.onPrimaryColor.withValues(alpha: 0),
                                  context.onPrimaryColor.withValues(alpha: 0.3),
                                  context.onPrimaryColor.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.lg),
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
            child: QuickStatItem(
              icon: Icons.account_balance_wallet_rounded,
              value: AppUtils.formatLargeNumber(stats?.walletBalance ?? 0),
              label: context.l10n.walletBalance,

            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.onPrimaryColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: QuickStatItem(
              icon: Icons.trending_up_rounded,
              value: '${(stats?.periodGrowth ?? 0).toStringAsFixed(1)}%',
              label: context.l10n.growth,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.onPrimaryColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: QuickStatItem(
              icon: Icons.person_rounded,
              value: stats?.topPayer ?? 'N/A',
              label: context.l10n.topPayer,
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
              size: context.md,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
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
                child: StatsWidgetCard(
                  icon: Icons.account_balance_wallet_rounded,
                  value: AppUtils.formatLargeNumber(stats?.totalAmount ?? 0),
                  label: context.l10n.totalBalance,
                  subtitle: context.l10n.walletBalance,
                ),
              ),
              const SizedBox(width: AppSpacing.sm1),
              Expanded(
                child: StatsWidgetCard(
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
                child: StatsWidgetCard(
                  icon: Icons.trending_up_rounded,
                  value: '+${(stats?.periodGrowth ?? 0).toStringAsFixed(1)}%',
                  label: context.l10n.growthWeekly,
                  subtitle: context.l10n.increaseFromPreviousPeriod,
                ),
              ),
              const SizedBox(width: AppSpacing.sm1),
              Expanded(
                child: StatsWidgetCard(
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

