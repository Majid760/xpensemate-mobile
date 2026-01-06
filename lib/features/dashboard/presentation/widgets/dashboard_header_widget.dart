import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class DashboardHeaderWidget extends StatelessWidget {
  const DashboardHeaderWidget({
    super.key,
    required this.state,
  });

  final DashboardState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: context.md),
        child: FinancialOverviewCard(state: state),
      );
}

// ==================== Financial Overview Card ====================
class FinancialOverviewCard extends StatefulWidget {
  const FinancialOverviewCard({
    super.key,
    required this.state,
  });

  final DashboardState state;

  @override
  State<FinancialOverviewCard> createState() => _FinancialOverviewCardState();
}

class _FinancialOverviewCardState extends State<FinancialOverviewCard>
    with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  bool _isExpanded = false;
  late AnimationController _fadeController;
  late AnimationController _expandController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weeklyStats = widget.state.weeklyStats;
    final weeklyBudget = weeklyStats?.weeklyBudget ?? 0.0;
    final totalSpent = weeklyStats?.weekTotal ?? 0.0;
    final availableBalance = weeklyStats?.balanceLeft ?? 0.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primary,
              context.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.primary.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: context.colorScheme.primary,
            child: InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    context.sm1, context.sm1, context.sm1, context.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section with Visibility Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.overview,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.colorScheme.onPrimary
                                      .withValues(alpha: 1),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: context.xs / 2),
                              Text(
                                context.l10n.weeklyInsights,
                                style:
                                    context.textTheme.headlineSmall?.copyWith(
                                  color: context.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Visibility Toggle Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleBalanceVisibility,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.colorScheme.onPrimary
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.colorScheme.onPrimary
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                _isBalanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: context.colorScheme.onPrimary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.md),

                    // Quick Stats Row - Always Visible
                    _QuickStatsRow(
                      weeklyBudget: weeklyBudget,
                      totalSpent: totalSpent,
                      availableBalance: availableBalance,
                      isBalanceVisible: _isBalanceVisible,
                    ),

                    SizedBox(height: context.md),

                    // Expand/Collapse Button - Centered Below Stats
                    Center(
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: context.colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ),

                    // Expandable Section
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1,
                      child: Column(
                        children: [
                          SizedBox(height: context.md),
                          // Divider
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.onPrimary
                                      .withValues(alpha: 0),
                                  context.colorScheme.onPrimary
                                      .withValues(alpha: 0.3),
                                  context.colorScheme.onPrimary
                                      .withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.md),
                          // Bottom Insights - 2 Column Layout
                          _WeeklyInsightsSection(
                            availableBalance: availableBalance,
                            highlyActiveBudgetGoal:
                                "woow", // TODO: Replace with real data if available
                            isBalanceVisible: _isBalanceVisible,
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
      ),
    );
  }
}

// ==================== Quick Stats Row ====================
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.weeklyBudget,
    required this.totalSpent,
    required this.availableBalance,
    required this.isBalanceVisible,
  });

  final double weeklyBudget;
  final double totalSpent;
  final double availableBalance;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.account_balance_wallet_rounded,
              value: isBalanceVisible
                  ? AppUtils.formatLargeNumber(weeklyBudget)
                  : '••••••',
              label: context.l10n.budget,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.arrow_upward_rounded,
              value: isBalanceVisible
                  ? AppUtils.formatLargeNumber(totalSpent)
                  : '••••••',
              label: context.l10n.spent,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.savings_rounded,
              value: isBalanceVisible
                  ? AppUtils.formatLargeNumber(availableBalance)
                  : '••••••',
              label: context.l10n.remaining,
            ),
          ),
        ],
      );
}

// ==================== Quick Stat Item ====================
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.colorScheme.onPrimary, size: 24),
          ),
          SizedBox(height: context.sm),
          Text(
            value,
            style: TextStyle(
              color: context.colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.xs / 2),
          Text(
            label,
            style: TextStyle(
              color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
}

// ==================== Weekly Insights Section ====================
class _WeeklyInsightsSection extends StatelessWidget {
  const _WeeklyInsightsSection({
    required this.availableBalance,
    required this.highlyActiveBudgetGoal,
    required this.isBalanceVisible,
  });

  final double availableBalance;
  final dynamic highlyActiveBudgetGoal;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _InsightCard(
              icon: Icons.account_balance_rounded,
              title:
                  'Remaining Balance', // TODO: Localize or use budgetStatistics
              value: isBalanceVisible
                  ? AppUtils.formatLargeNumber(availableBalance)
                  : '••••••',
              subtitle: availableBalance > 0
                  ? "You're doing great!" // TODO: Localize
                  : 'Budget exceeded', // TODO: Localize
            ),
          ),
          SizedBox(width: context.sm1),
          Expanded(
            child: _InsightCard(
              icon: Icons.flag_rounded,
              title: 'Most Active Goal', // TODO: Localize
              value: 'No goals', // TODO: Localize
              subtitle: highlyActiveBudgetGoal != null
                  ? '23 days used' // TODO: Localize
                  : 'Create a budget goal', // TODO: Localize
            ),
          ),
        ],
      );
}

// ==================== Insight Card ====================
class _InsightCard extends StatefulWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colorScheme.onPrimary
                    .withValues(alpha: _isHovered ? 0.25 : 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colorScheme.onPrimary
                      .withValues(alpha: _isHovered ? 0.4 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.1),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: Offset(0, _isHovered ? 6 : 4),
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
                          color: context.colorScheme.onPrimary
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 18,
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colorScheme.onPrimary
                                .withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.sm1),
                  Text(
                    widget.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: context.xs + 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color:
                          context.colorScheme.onPrimary.withValues(alpha: 0.75),
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
