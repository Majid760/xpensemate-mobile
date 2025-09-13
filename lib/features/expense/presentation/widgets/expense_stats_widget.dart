import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

class ExpenseStatsWidget extends StatelessWidget {
  const ExpenseStatsWidget({super.key, required this.stats});
  final ExpenseStatsEntity? stats;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        expandedHeight: 310,
        pinned: true,
        stretch: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        centerTitle: true,
        clipBehavior: Clip.none,
        actionsPadding: const EdgeInsets.only(right: 8),
        flexibleSpace: FlexibleSpaceBar(
          background: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: .8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First row of stats
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.attach_money_rounded,
                                  title: 'TOTAL SPENT',
                                  value: CurrencyFormatter.format(
                                    stats?.totalSpent ?? 0,
                                  ),
                                  subtitle: 'Total spent in this period',
                                  color: Colors.blue,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              Expanded(
                                child: StatCard(
                                  color: Colors.orange,
                                  title: 'DAILY AVERAGE',
                                  value: CurrencyFormatter.format(
                                    stats?.dailyAverage ?? 0,
                                  ),
                                  subtitle: 'Average spent per day',
                                  icon: Icons.bar_chart_rounded,
                                ),
                              ),
                            ],
                          ),
                          // Divider
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                            margin: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          // Second row of stats
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.trending_up_rounded,
                                  title: 'SPENDING VELOCITY',
                                  value:
                                      '${(stats?.spendingVelocityPercent ?? 0).toStringAsFixed(1)}%',
                                  subtitle: stats?.spendingVelocityMessage ??
                                      'No data available',
                                  color: Colors.green,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.white.withValues(
                                  alpha: .2,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.star_rounded,
                                  title: 'TRACKING STREAK',
                                  value: '${stats?.trackingStreak ?? 0}',
                                  subtitle: 'consecutive days',
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  ExpenseStatsEntity _getDefaultStats() => ExpenseStatsEntity(
        totalSpent: 0,
        dailyAverage: 0,
        spendingVelocityPercent: 0,
        spendingVelocityMessage: 'No data available',
        trackingStreak: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        trend: [],
        categories: [],
      );
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
}
