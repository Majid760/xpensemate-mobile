import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

class ExpenseStatsWidget extends StatefulWidget {
  const ExpenseStatsWidget({super.key, required this.stats});
  final ExpenseStatsEntity? stats;

  @override
  State<ExpenseStatsWidget> createState() => _ExpenseStatsWidgetState();
}

class _ExpenseStatsWidgetState extends State<ExpenseStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _statsAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _containerAnimation;
  late Animation<double> _cardAnimation;
  late ExpenseStatsEntity stats;

  @override
  void initState() {
    super.initState();
    stats = widget.stats ?? _getDefaultStats();
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _containerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _statsAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _statsAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _statsAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

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
        leading: Text(
          'Expenses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) => FlexibleSpaceBar(
            background:
                // Main background content
                AnimatedBuilder(
              animation: _containerAnimation,
              builder: (context, child) {
                final animationValue =
                    _containerAnimation.value.clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 0.8 + (0.2 * animationValue),
                  child: Opacity(
                    opacity: animationValue,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withValues(alpha: .8),
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
                              Stack(
                                children: [
                                  AnimatedBuilder(
                                    animation: _cardAnimation,
                                    builder: (context, child) {
                                      final animationValue =
                                          _cardAnimation.value.clamp(0.0, 1.0);
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          30 * (1 - animationValue),
                                        ),
                                        child: Transform.scale(
                                          scale: 0.9 + (0.1 * animationValue),
                                          child: Opacity(
                                            opacity: animationValue,
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
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
                                                          icon: Icons
                                                              .attach_money_rounded,
                                                          title: 'TOTAL SPENT',
                                                          value:
                                                              CurrencyFormatter
                                                                  .format(
                                                            stats.totalSpent,
                                                          ),
                                                          subtitle:
                                                              'Total spent in this period',
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 50,
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: 0.2,
                                                        ),
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: StatCard(
                                                          color: Colors.orange,
                                                          title:
                                                              'DAILY AVERAGE',
                                                          value:
                                                              CurrencyFormatter
                                                                  .format(
                                                            stats.dailyAverage,
                                                          ),
                                                          subtitle:
                                                              'Average spent per day',
                                                          icon: Icons
                                                              .bar_chart_rounded,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Divider
                                                  Container(
                                                    height: 1,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                  // Second row of stats
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: StatCard(
                                                          icon: Icons
                                                              .trending_up_rounded,
                                                          title:
                                                              'SPENDING VELOCITY',
                                                          value:
                                                              '+${stats.spendingVelocityPercent.toStringAsFixed(1)}%',
                                                          subtitle: stats
                                                              .spendingVelocityMessage,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 50,
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: .2,
                                                        ),
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: StatCard(
                                                          icon: Icons
                                                              .star_rounded,
                                                          title:
                                                              'TRACKING STREAK',
                                                          value:
                                                              '${stats.trackingStreak}',
                                                          subtitle:
                                                              'consecutive days',
                                                          color: Colors.purple,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
