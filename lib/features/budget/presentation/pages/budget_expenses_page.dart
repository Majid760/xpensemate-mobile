import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_state.dart';
import 'package:xpensemate/features/budget/presentation/widgets/expense_card.dart';
import 'package:xpensemate/features/budget/presentation/widgets/expense_stats_header.dart';
import 'package:xpensemate/features/budget/presentation/widgets/search_filter.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, required this.budgetGoal});
  final BudgetGoalEntity budgetGoal;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    if (context.mounted) {
      context.budgetExpensesCubit
          .getBudgetSpecificExpenses(widget.budgetGoal.id);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocBuilder<BudgetExpensesCubit, BudgetExpensesState>(
          builder: (context, state) {
            // Show loading indicator when initially loading
            if (state.isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error message if there's an error and no data
            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    ElevatedButton(
                      onPressed: () {
                        context.budgetExpensesCubit
                            .getBudgetSpecificExpenses(widget.budgetGoal.id);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show data if available
            final expenses = state.budgetGoals?.expenses ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Animated Header (scrollable)
                SliverToBoxAdapter(
                  child: const AnimatedExpenseHeader(
                    category: 'fun and entertainment Expenses',
                    budgetGoal: 'funn',
                    totalSpent: 262,
                    average: 87.33,
                    transactions: 3,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Sticky Search and Filter Bar
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: SearchBarDelegate(
                    minHeight: 90.0,
                    maxHeight: 120.0,
                    child: Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      alignment: Alignment.center,
                      child: const SearchAndFilterBar(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Budget Progress
                SliverToBoxAdapter(
                  child: const AnimatedWidget(
                    delay: 200,
                    child: BudgetProgressBar(
                      category: 'funn',
                      subtitle: '(fun and entertainment)',
                      budget: 1243,
                      spent: 262,
                      remaining: 981,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Expense List
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

                // Loading indicator at bottom
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      );
}

// Custom delegate for the sticky search bar
class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  SearchBarDelegate({
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxHeight,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: category),
                    TextSpan(
                      text: '  $subtitle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _BudgetLabel('Budget', budget, Colors.grey[600]!),
                  _BudgetLabel('Spent', spent, Colors.grey[600]!),
                  _BudgetLabel('Remaining', remaining, Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
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
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}
