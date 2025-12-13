import 'package:flutter/material.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

class ExpenseStatsWidget extends StatefulWidget {
  const ExpenseStatsWidget(
      {super.key, required this.stats, required this.filter});
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
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                                'Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.filter.name.capitalize} Insights',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Quick Stats Row (Abstract - Always Visible)
                      _QuickStatsRow(stats: widget.stats),
                      // Expandable Detailed Section
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 20),
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
              label: 'Total Spent',
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
              icon: Icons.calendar_today_rounded,
              value: CurrencyFormatter.format(stats?.dailyAverage ?? 0),
              label: 'Daily Average',
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
              icon: Icons.local_fire_department_rounded,
              value: '${stats?.trackingStreak ?? 0}',
              label: 'Streak',
              iconBg: Colors.white.withValues(alpha: 0.2),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
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
                child: _StatsCard(
                  icon: Icons.attach_money_rounded,
                  value: CurrencyFormatter.format(stats?.totalSpent ?? 0),
                  label: 'Total Spent',
                  subtitle: 'Total spent in  period',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  icon: Icons.bar_chart_rounded,
                  value: CurrencyFormatter.format(stats?.dailyAverage ?? 0),
                  label: 'Daily Average',
                  subtitle: 'Average spent per day',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  icon: Icons.trending_up_rounded,
                  value:
                      '${(stats?.spendingVelocityPercent ?? 0).toStringAsFixed(1)}%',
                  label: 'Spending Velocity',
                  subtitle: stats?.spendingVelocityMessage ?? 'No data',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  icon: Icons.local_fire_department_rounded,
                  value: '${stats?.trackingStreak ?? 0}',
                  label: 'Tracking Streak',
                  subtitle: 'Consecutive days',
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.value,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
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
