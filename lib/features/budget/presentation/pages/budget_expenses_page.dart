import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_state.dart';
import 'package:xpensemate/features/budget/presentation/widgets/expense_card.dart';
import 'package:xpensemate/features/budget/presentation/widgets/search_filter.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, required this.budgetGoal});
  final BudgetGoalEntity budgetGoal;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with SingleTickerProviderStateMixin {
  bool _isHeaderExpanded = false;
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

    if (context.mounted) {
      context.budgetExpensesCubit
          .getBudgetSpecificExpenses(widget.budgetGoal.id);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleHeaderExpansion() {
    setState(() {
      _isHeaderExpanded = !_isHeaderExpanded;
      if (_isHeaderExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: BlocConsumer<BudgetExpensesCubit, BudgetExpensesState>(
          listener: (context, state) {
            if (state.hasError && state.message != null) {
              AppSnackBar.show(context: context, message: state.message!);
            }
          },
          builder: (context, state) {
            // Show loading indicator when initially loading
            if (state.isInitialLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            // Show error message if there's an error and no data
            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ErrorStateSectionWidget(
                      errorMsg:
                          '${context.l10n.errorGeneric}: ${state.message}',
                      onRetry: () {
                        context.budgetExpensesCubit
                            .getBudgetSpecificExpenses(widget.budgetGoal.id);
                      },
                    ),
                  ],
                ),
              );
            }

            // Show data if available
            final expenses = state.budgetGoals?.expenses ?? [];
            final originalExpenses = state.originalBudgetGoals?.expenses ?? [];
            final budgetGoal = widget.budgetGoal;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Animated Header (scrollable) - now shows stats based on original unfiltered data
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      // Calculate stats based on original unfiltered expenses
                      final originalExpensesTotal =
                          originalExpenses.fold<double>(
                        0,
                        (sum, expense) => sum + expense.amount,
                      );

                      return ExpandableExpenseHeader(
                        isExpanded: _isHeaderExpanded,
                        onToggle: _toggleHeaderExpansion,
                        animation: _expandAnimation,
                        category: '${budgetGoal.name} ${context.l10n.expenses}',
                        budgetGoal: budgetGoal.name,
                        totalSpent: originalExpensesTotal,
                        average: originalExpenses.isNotEmpty
                            ? originalExpensesTotal / originalExpenses.length
                            : 0,
                        transactions: originalExpenses.length,
                        budgetAmount: budgetGoal.amount, // New parameter
                        remaining: budgetGoal.amount -
                            originalExpensesTotal, // New parameter
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),

                // Sticky Search and Filter Bar with expandable dropdown
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ExpandableSearchBarDelegate(
                    minHeight: 100,
                    maxHeight:
                        100, // Increased height to accommodate filter content
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const SearchAndFilterBar(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),

                // Expense List - shows filtered expenses
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = expenses[index];
                        return AnimatedWidget(
                          delay: 250 + (index * 100),
                          child: ExpenseCard(
                            expense: ExpenseItem(
                              name: expense.name,
                              amount: expense.amount,
                              date: expense.date,
                              time: expense.time,
                              paymentMethod: expense.paymentMethod,
                            ),
                          ),
                        );
                      },
                      childCount: expenses.length,
                    ),
                  ),
                ),
                if (expenses.isEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: context.colorScheme.outline,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.noDataAvailable,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Show message when no expenses match the filter
                if (expenses.isEmpty &&
                    (state.originalBudgetGoals?.expenses ?? []).isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: context.colorScheme.outline,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.noDataAvailable,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.tryAgain,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Loading indicator at bottom
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child:
                          Center(child: CircularProgressIndicator.adaptive()),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],
            );
          },
        ),
      );
}

// Custom delegate for expandable sticky search bar
class ExpandableSearchBarDelegate extends SliverPersistentHeaderDelegate {
  ExpandableSearchBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      SizedBox(
        height: maxHeight,
        child: child,
      );

  @override
  bool shouldRebuild(covariant ExpandableSearchBarDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
}

// Animated Widget Wrapper with fade and slide animation
class AnimatedWidget extends StatefulWidget {
  const AnimatedWidget({
    super.key,
    required this.child,
    this.delay = 0,
  });
  final Widget child;
  final int delay;

  @override
  State<AnimatedWidget> createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      );
}

// Expandable Expense Header with expansion functionality similar to insight_card_section.dart
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
  State<ExpandableExpenseHeader> createState() =>
      _ExpandableExpenseHeaderState();
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
                                  color: context.colorScheme.shadow
                                      .withValues(alpha: 0.16),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expand/Collapse indicator with animated rotation
                        AnimatedRotation(
                          turns: widget.isExpanded
                              ? 0.5
                              : 0, // Rotate 180 degrees when expanded
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colorScheme.onPrimary
                                  .withValues(alpha: 0.2),
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
                        color: context.colorScheme.onPrimary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.colorScheme.onPrimary
                              .withValues(alpha: 0.3),
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
                          const SizedBox(height: 24),
                          // Detailed budget information using the existing AnimatedExpenseHeader's budget progress section
                          _DetailedBudgetInfo(
                            budget: widget.budgetAmount,
                            spent: widget.totalSpent,
                            remaining: widget.remaining,
                            progress: widget.budgetAmount > 0
                                ? (widget.totalSpent / widget.budgetAmount)
                                    .clamp(0.0, 1.0)
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
  Widget _buildStatCard(BuildContext context,
          {required IconData icon,
          required String label,
          required String value}) =>
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
  List<Color> _getProgressGradientColors(
      BuildContext context, double progress) {
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

// Budget Progress Bar with shadow
class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.category,
    required this.subtitle,
    required this.budget,
    required this.spent,
    required this.remaining,
  });
  final String category;
  final String subtitle;
  final double budget;
  final double spent;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final progress = spent / budget;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondaryFixed.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(text: category),
                    TextSpan(
                      text: '  $subtitle',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: 8,
                children: [
                  _BudgetLabel(context.l10n.budget, budget,
                      colorScheme.onSurfaceVariant),
                  _BudgetLabel(
                      context.l10n.spent, spent, colorScheme.onSurfaceVariant),
                  _BudgetLabel(
                      context.l10n.remaining, remaining, context.primaryColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0), // Clamp value between 0 and 1
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
                minHeight: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetLabel extends StatelessWidget {
  const _BudgetLabel(this.label, this.amount, this.color);
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}
