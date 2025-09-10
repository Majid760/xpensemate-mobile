import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_custom_dropdown_widget.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_list_header_widget.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_list_widget.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_stats_widget.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const ExpensePageBody(),
      );
}

class ExpensePageBody extends StatelessWidget {
  const ExpensePageBody({super.key});

  @override
  Widget build(BuildContext context) => const ExpensePageContent();
}

class ExpensePageContent extends StatefulWidget {
  const ExpensePageContent({super.key});

  @override
  State<ExpensePageContent> createState() => _ExpensePageContentState();
}

class _ExpensePageContentState extends State<ExpensePageContent>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadExpenseData() {
    context.read<ExpenseCubit>().loadExpenseData();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state.state == ExpenseStates.error &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            AppSnackBar.show(
              context: context,
              message: state.errorMessage ?? "",
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) => Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            RefreshIndicator(
              onRefresh: () async => _loadExpenseData(),
              color: Theme.of(context).primaryColor,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  ExpenseStatsWidget(stats: state.expenseStats),
                  const ExpenseListHeaderWidget(),
                  ExpenseListWidget(
                    onEdit: (expenseId) {},
                    onDelete: (expenseId) {
                      if (state.expenses?.expenses.isEmpty ?? true) return;
                      AppCustomDialogs.showDelete(
                        context: context,
                        title: 'Delete expense',
                        message:
                            'Are you sure you want to delete this expense?',
                        onConfirm: () {},
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                  // Bottom padding for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 60,
              right: 20,
              child: CustomDropDown(
                defaultValue: "weekly",
                value: ["weekly", "monthly", "yearly"],
                onChanged: (period) {
                  if (period != null) {
                    context.expenseCubit
                        .loadExpenseStats(period: period.toLowerCase());
                  }
                },
              ),
            ),
          ],
        ),
      );
}

class MockExpense {
  MockExpense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
  });
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;
}

// New Stats Sliver Widget with Dropdown
class ExpenseStatsSliver extends StatefulWidget {
  const ExpenseStatsSliver({super.key});

  @override
  State<ExpenseStatsSliver> createState() => _ExpenseStatsSliverState();
}

class _ExpenseStatsSliverState extends State<ExpenseStatsSliver>
    with TickerProviderStateMixin {
  late AnimationController _statsAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _containerAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

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

        // actions: [_buildAnimatedDropdown(context)],
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
                            Theme.of(context).primaryColor.withOpacity(0.8),
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
                                  _buildSingleStatsCard(context),
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

  Widget _buildSingleStatsCard(BuildContext context) => AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          final animationValue = _cardAnimation.value.clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, 30 * (1 - animationValue)),
            child: Transform.scale(
              scale: 0.9 + (0.1 * animationValue),
              child: Opacity(
                opacity: animationValue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First row of stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              Icons.attach_money_rounded,
                              'TOTAL SPENT',
                              '\$2,692',
                              'Total spent in this period',
                              Colors.blue,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              Icons.calendar_today_rounded,
                              'DAILY AVERAGE',
                              '\$385',
                              'Average spent per day',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      // Divider
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      // Second row of stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              Icons.trending_up_rounded,
                              'SPENDING VELOCITY',
                              '+401.3%',
                              'Spending 401% more than last week',
                              Colors.green,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              Icons.star_rounded,
                              'TRACKING STREAK',
                              '0',
                              'consecutive days',
                              Colors.purple,
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
      );

  Widget _buildStatItem(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
}

// Expenses List Header Widget
class ExpenseListHeader extends StatelessWidget {
  const ExpenseListHeader({super.key});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Expenses",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // View all expenses
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View all'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
}

// Updated Expense List Item Widget
class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    this.isLast = false,
  });
  final MockExpense expense;
  final bool isLast;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(
          bottom: isLast ? 0 : 12,
        ),
        child: Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: HapticFeedback.lightImpact,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: expense.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      expense.icon,
                      color: expense.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: expense.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expense.category,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: expense.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(expense.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(expense.amount.abs()),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: expense.amount < 0
                                      ? Theme.of(context).colorScheme.error
                                      : Colors.green,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.green,
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
}
