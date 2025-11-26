// Expandable Expense Header with expansion functionality similar to insight_card_section.dart
import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class ExpandableExpenseHeader extends StatefulWidget {
  const ExpandableExpenseHeader({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.animation,
    required this.category,
    required this.budgetGoal,
    required this.totalSpent,
    required this.average,
    required this.transactions,
    required this.budgetAmount,
    required this.remaining,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final Animation<double> animation;
  final String category;
  final String budgetGoal;
  final double totalSpent;
  final double average;
  final int transactions;
  final double budgetAmount;
  final double remaining;

  @override
  State<ExpandableExpenseHeader> createState() => _ExpandableExpenseHeaderState();
}

class _ExpandableExpenseHeaderState extends State<ExpandableExpenseHeader> {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.primaryColor,
              context.primaryColor.withValues(alpha: 0.8),
              context.primaryColor.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.15),
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
              onTap: widget.onToggle,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with title and expand/collapse indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.category,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: context.colorScheme.shadow.withValues(alpha: 0.16),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expand/Collapse indicator with animated rotation
                        AnimatedRotation(
                          turns: widget.isExpanded ? 0.5 : 0, // Rotate 180 degrees when expanded
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Budget goal info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        context.l10n.budgetGoalLabel(widget.budgetGoal),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Basic stats row (always visible)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.percent_outlined,
                            label: context.l10n.totalSpent,
                            value:
                                '${(widget.budgetAmount > 0 ? (widget.totalSpent / widget.budgetAmount).clamp(0.0, 1.0) * 100 : 0).toStringAsFixed(1)}%',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.trending_up_rounded,
                            label: context.l10n.average,
                            value: '\$${widget.average.toStringAsFixed(2)}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.receipt_outlined,
                            label: context.l10n.transactions,
                            value: widget.transactions.toString(),
                          ),
                        ),
                      ],
                    ),
                    // Expanded section with detailed stats (only visible when expanded)
                    SizeTransition(
                      sizeFactor: widget.animation,
                      axisAlignment: -1,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.onPrimary.withValues(alpha: 0),
                                  context.colorScheme.onPrimary.withValues(alpha: 0.3),
                                  context.colorScheme.onPrimary.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Detailed budget information using the existing AnimatedExpenseHeader's budget progress section
                          _DetailedBudgetInfo(
                            budget: widget.budgetAmount,
                            spent: widget.totalSpent,
                            remaining: widget.remaining,
                            progress: widget.budgetAmount > 0
                                ? (widget.totalSpent / widget.budgetAmount).clamp(0.0, 1.0)
                                : 0.0,
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
      );

  // Helper method to build stat cards
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.1),
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
                color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: context.colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.95),
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
                value,
                style: TextStyle(
                  color: context.colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                      color: context.colorScheme.shadow.withValues(alpha: 0.16),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// Detailed Budget Information (similar to _BudgetProgressCard in expense_stats_header.dart)
class _DetailedBudgetInfo extends StatelessWidget {
  const _DetailedBudgetInfo({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
  });

  final double budget;
  final double spent;
  final double remaining;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BudgetInfoItem(
                  label: context.l10n.budget,
                  value: '\$${budget.toStringAsFixed(2)}',
                  color: context.colorScheme.onPrimary,
                ),
                _BudgetInfoItem(
                  label: context.l10n.spent,
                  value: '\$${spent.toStringAsFixed(2)}',
                  color: context.colorScheme.onPrimary,
                ),
                _BudgetInfoItem(
                  label: context.l10n.remaining,
                  value: '\$${remaining.toStringAsFixed(2)}',
                  color: _getRemainingColor(context, remaining),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ..._getProgressGradientColors(context, 1),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getProgressGradientColors(context, progress),
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
                  color: context.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  // Get color for remaining amount based on value
  Color _getRemainingColor(BuildContext context, double remaining) {
    if (remaining >= 0) {
      // Green for positive remaining balance
      return context.colorScheme.primary.withValues(alpha: 0.7);
    } else {
      // Red for negative remaining balance (over budget)
      return context.colorScheme.error.withValues(alpha: 0.7);
    }
  }

  // Get gradient colors for progress bar based on progress
  List<Color> _getProgressGradientColors(BuildContext context, double progress) {
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
        context.colorScheme.tertiary.withValues(alpha: 0.8),
        context.colorScheme.primary.withValues(alpha: 0.8),
      ];
    } else {
      // Red gradient for > 100% usage (over budget)
      return [
        context.colorScheme.error.withValues(alpha: 0.8),
        context.colorScheme.error.withValues(alpha: 0.6),
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
              color: color.withValues(alpha: 0.8),
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
