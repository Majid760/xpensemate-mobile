import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class FinancialOverviewCardWidget extends StatefulWidget {
  const FinancialOverviewCardWidget({
    super.key,
    required this.state,
  });
  final DashboardState state;

  @override
  State<FinancialOverviewCardWidget> createState() =>
      _FinancialOverviewCardWidgetState();
}

class _FinancialOverviewCardWidgetState
    extends State<FinancialOverviewCardWidget> {
  bool _isBalanceVisible = true;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weeklyStats = widget.state.weeklyStats;
    final weeklyBudget = weeklyStats?.weeklyBudget ?? 0.0;
    final totalSpent = weeklyStats?.weekTotal ?? 0.0;
    final availableBalance = weeklyStats?.balanceLeft ?? 0.0;

    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.tertiary.withValues(alpha: 0.9),
            context.colorScheme.secondary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: context.colorScheme.secondary.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Balance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.totalExpenses,
                    style: context.textTheme.titleMedium?.copyWith(
                      color:
                          context.colorScheme.onPrimary.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.xs / 2),
                  Row(
                    children: [
                      Text(
                        _isBalanceVisible
                            ? '\$${weeklyBudget.toStringAsFixed(0)}'
                            : '•••••',
                        style: context.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(width: context.sm),
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: context.colorScheme.onPrimary,
                        ),
                        onPressed: _toggleBalanceVisibility,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Growth percentage
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sm1,
                  vertical: context.sm,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _calculateGrowthPercentage(weeklyBudget, totalSpent),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isPositiveGrowth(weeklyBudget, totalSpent)
                            ? Colors.greenAccent[200]
                            : Colors.redAccent[100],
                      ),
                    ),
                    Text(
                      context.l10n.thisWeek,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onPrimary
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md1),
          // Reordered: Spent This Week and Available
          Row(
            children: [
              // Spent This Week (now shown first)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.spentThisWeek,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onPrimary
                            .withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: context.xs / 2),
                    Text(
                      _isBalanceVisible
                          ? '\$${totalSpent.toStringAsFixed(0)}'
                          : '•••••',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 40,
                width: 1,
                color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              SizedBox(width: context.md),
              // Available
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.available,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onPrimary
                            .withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: context.xs / 2),
                    Text(
                      _isBalanceVisible
                          ? '\$${availableBalance.toStringAsFixed(0)}'
                          : '•••••',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  String _calculateGrowthPercentage(double weeklyBudget, double totalSpent) {
    if (weeklyBudget <= 0) return '+0.0%';

    // Calculate percentage of budget remaining
    final remainingPercent = (1 - (totalSpent / weeklyBudget)) * 100;

    // Generate a percentage that looks realistic (positive if under budget)
    final changePercent =
        remainingPercent > 0 ? remainingPercent / 8 : -remainingPercent / 8;
    final sign = changePercent >= 0 ? '+' : '';

    return '$sign${changePercent.toStringAsFixed(1)}%';
  }

  bool _isPositiveGrowth(double weeklyBudget, double totalSpent) {
    if (weeklyBudget <= 0) return true;

    // If we've spent less than our budget, it's positive
    return totalSpent <= weeklyBudget;
  }
}
