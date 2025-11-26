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
import 'package:xpensemate/features/budget/presentation/widgets/expandable_expense_header.dart';
import 'package:xpensemate/features/budget/presentation/widgets/expense_card.dart';
import 'package:xpensemate/features/budget/presentation/widgets/search_filter.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, required this.budgetGoal});
  final BudgetGoalEntity budgetGoal;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with SingleTickerProviderStateMixin {
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
      context.budgetExpensesCubit.getBudgetSpecificExpenses(widget.budgetGoal.id);
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
                      errorMsg: '${context.l10n.errorGeneric}: ${state.message}',
                      onRetry: () {
                        context.budgetExpensesCubit.getBudgetSpecificExpenses(widget.budgetGoal.id);
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
                      final originalExpensesTotal = originalExpenses.fold<double>(
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
                        average: originalExpenses.isNotEmpty ? originalExpensesTotal / originalExpenses.length : 0,
                        transactions: originalExpenses.length,
                        budgetAmount: budgetGoal.amount, // New parameter
                        remaining: budgetGoal.amount - originalExpensesTotal, // New parameter
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
                    maxHeight: 100, // Increased height to accommodate filter content
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
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: context.colorScheme.outline,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.noDataAvailable,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Show message when no expenses match the filter
                if (expenses.isEmpty && (state.originalBudgetGoals?.expenses ?? []).isNotEmpty)
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
                      child: Center(child: CircularProgressIndicator.adaptive()),
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

class _AnimatedWidgetState extends State<AnimatedWidget> with SingleTickerProviderStateMixin {
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
                  _BudgetLabel(context.l10n.budget, budget, colorScheme.onSurfaceVariant),
                  _BudgetLabel(context.l10n.spent, spent, colorScheme.onSurfaceVariant),
                  _BudgetLabel(context.l10n.remaining, remaining, context.primaryColor),
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
