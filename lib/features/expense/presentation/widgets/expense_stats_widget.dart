import 'package:flutter/material.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/core/widget/stat_widget.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

class ExpenseStatsWidget extends StatefulWidget {
  const ExpenseStatsWidget({
    super.key,
    required this.stats,
    required this.filter,
  });

  final ExpenseStatsEntity? stats;
  final FilterValue filter;

  @override
  State<ExpenseStatsWidget> createState() => _ExpenseStatsWidgetState();
}

class _ExpenseStatsWidgetState extends State<ExpenseStatsWidget>
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
    AppUtils.hapticFeedback();
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
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.fromLTRB(
            context.md,
            context.xs,
            context.md,
            context.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.primaryColor,
                context.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: context.primaryColor,
              child: InkWell(
                onTap: _toggleExpanded,
                child: Padding(
                  padding: EdgeInsets.all(context.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.overview,
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    color: context.onPrimaryColor
                                        .withValues(alpha: 0.7),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: context.xs),
                                Text(
                                  widget.filter
                                      .getLocalizedInsightsTitle(context),
                                  style:
                                      context.textTheme.headlineSmall?.copyWith(
                                    color: context.onPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              padding: EdgeInsets.all(context.sm),
                              decoration: BoxDecoration(
                                color: context.onPrimaryColor
                                    .withValues(alpha: 0.2),
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
                      SizedBox(height: context.lg),
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
                                    context.onPrimaryColor
                                        .withValues(alpha: 0.3),
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
        ),
      );
}

// Quick Stats Row - Abstract view (collapsed state)
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});
  final ExpenseStatsEntity? stats;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.account_balance_wallet_rounded,
              value: CurrencyFormatter.format(stats?.totalSpent ?? 0),
              label: context.l10n.totalSpent,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.calendar_today_rounded,
              value: CurrencyFormatter.format(stats?.dailyAverage ?? 0),
              label: context.l10n.dailyAverage,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.local_fire_department_rounded,
              value: '${stats?.trackingStreak ?? 0}',
              label: context.l10n.streak,
            ),
          ),
        ],
      );

  Widget _buildDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withValues(alpha: 0.2),
      );
}

class _QuickStatItem extends StatelessWidget {
  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.sm),
            decoration: BoxDecoration(
              color: context.onPrimaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.onPrimaryColor, size: 24),
          ),
          SizedBox(height: context.xs),
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
          SizedBox(height: context.xs / 2),
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
  final ExpenseStatsEntity? stats;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsWidgetCard(
                  icon: Icons.attach_money_rounded,
                  value: CurrencyFormatter.format(stats?.totalSpent ?? 0),
                  label: context.l10n.totalSpent,
                  subtitle: context.l10n.totalSpentSubtitle,
                ),
              ),
              SizedBox(width: context.sm),
              Expanded(
                child: StatsWidgetCard(
                  icon: Icons.bar_chart_rounded,
                  value: CurrencyFormatter.format(stats?.dailyAverage ?? 0),
                  label: context.l10n.dailyAverage,
                  subtitle: context.l10n.dailyAverageSubtitle,
                ),
              ),
            ],
          ),
          SizedBox(height: context.sm),
          Row(
            children: [
              Expanded(
                child: StatsWidgetCard(
                  icon: Icons.trending_up_rounded,
                  value:
                      '${(stats?.spendingVelocityPercent ?? 0).toStringAsFixed(1)}%',
                  label: context.l10n.spendingVelocity,
                  subtitle: stats?.spendingVelocityMessage ??
                      context.l10n.noDataAvailable,
                ),
              ),
              SizedBox(width: context.sm),
              Expanded(
                child: StatsWidgetCard(
                  icon: Icons.local_fire_department_rounded,
                  value: '${stats?.trackingStreak ?? 0}',
                  label: context.l10n.trackingStreak,
                  subtitle: context.l10n.consecutiveDays,
                ),
              ),
            ],
          ),
        ],
      );
}
