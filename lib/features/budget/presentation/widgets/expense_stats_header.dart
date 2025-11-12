// Animated Expense Header
import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class AnimatedExpenseHeader extends StatefulWidget {
  const AnimatedExpenseHeader({
    super.key,
    required this.category,
    required this.budgetGoal,
    required this.totalSpent,
    required this.average,
    required this.transactions,
    required this.budgetAmount, // Added budget amount
    required this.remaining, // Added remaining amount
  });
  final String category;
  final String budgetGoal;
  final double totalSpent;
  final double average;
  final int transactions;
  final double budgetAmount; // New parameter
  final double remaining; // New parameter

  @override
  State<AnimatedExpenseHeader> createState() => _AnimatedExpenseHeaderState();
}

class _AnimatedExpenseHeaderState extends State<AnimatedExpenseHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final currencySymbol = '\$'; // Will be updated when localization is regenerated
    final budgetGoalLabel = localizations != null
        ? 'Budget Goal: ${widget.budgetGoal}' // Will be updated when localization is regenerated
        : 'Budget Goal: ${widget.budgetGoal}';

    // Calculate progress percentage
    final progress = widget.budgetAmount > 0 ? (widget.totalSpent / widget.budgetAmount).clamp(0.0, 1.0) : 0.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.16),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              budgetGoalLabel,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats Cards in horizontal row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.percent_outlined, // Changed to percentage icon
                        label: localizations?.totalSpent ?? 'Usage %', // Changed label
                        value: '${(progress * 100).toStringAsFixed(1)}%', // Show percentage
                        delay: 100,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        label: localizations != null
                            ? 'Average'
                            : 'Average', // Will be updated when localization is regenerated
                        value: '$currencySymbol${widget.average.toStringAsFixed(2)}',
                        delay: 200,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.receipt_outlined,
                        label: localizations != null
                            ? 'Transactions'
                            : 'Transactions', // Will be updated when localization is regenerated
                        value: widget.transactions.toString(),
                        delay: 300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Budget Progress Section
                _BudgetProgressCard(
                  budget: widget.budgetAmount,
                  spent: widget.totalSpent,
                  remaining: widget.remaining,
                  progress: progress,
                  currencySymbol: currencySymbol,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Stat Card with individual animation
class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.delay,
  });
  final IconData icon;
  final String label;
  final String value;
  final int delay;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.95),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.16),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// Budget Progress Card
class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.currencySymbol,
  });

  final double budget;
  final double spent;
  final double remaining;
  final double progress;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BudgetInfoItem(
                  label: 'Budget',
                  value: '$currencySymbol${budget.toStringAsFixed(2)}',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                _BudgetInfoItem(
                  label: 'Spent',
                  value: '$currencySymbol${spent.toStringAsFixed(2)}',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                _BudgetInfoItem(
                  label: 'Remaining',
                  value: '$currencySymbol${remaining.toStringAsFixed(2)}',
                  color: _getRemainingColor(
                    context,
                    remaining,
                  ), // More vibrant color
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar with more vibrant colors
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ..._getProgressGradientColors(
                      context,
                      1,
                    ), // Use full gradient for background
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getProgressGradientColors(
                        context,
                        progress,
                      ), // More vibrant gradient
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress percentage
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}% used',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600, // Bolder font
                ),
              ),
            ),
          ],
        ),
      );

  // Get vibrant color for remaining amount based on value
  Color _getRemainingColor(BuildContext context, double remaining) {
    if (remaining >= 0) {
      // Green for positive remaining balance
      return Colors.greenAccent.shade200;
    } else {
      // Red for negative remaining balance (over budget)
      return Colors.redAccent.shade200;
    }
  }

  // Get vibrant gradient colors for progress bar based on progress
  List<Color> _getProgressGradientColors(
    BuildContext context,
    double progress,
  ) {
    if (progress < 0.5) {
      // Green gradient for < 50% usage
      return [
        context.primaryColor,
        context.secondaryColor,
      ];
    } else if (progress < 0.75) {
      // Yellow gradient for 50-75% usage
      return [
        context.secondaryColor,
        context.primaryColor,
      ];
    } else if (progress < 1.0) {
      // Orange gradient for 75-100% usage
      return [
        Colors.orangeAccent.shade200,
        Colors.deepOrangeAccent.shade200,
      ];
    } else {
      // Red gradient for > 100% usage (over budget)
      return [
        Colors.redAccent.shade200,
        Colors.deepOrangeAccent.shade200,
      ];
    }
  }
}

// Budget Info Item
class _BudgetInfoItem extends StatelessWidget {
  const _BudgetInfoItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}
