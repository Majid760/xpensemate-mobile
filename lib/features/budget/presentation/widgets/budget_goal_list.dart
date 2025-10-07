import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';
import 'package:xpensemate/features/budget/presentation/widgets/budget_card_item.dart';

class BudgetGoalsListWidget extends StatefulWidget {
  const BudgetGoalsListWidget({
    super.key,
    this.scrollController,
    this.scrollThreshold = 10,
  });

  final ScrollController? scrollController;
  final int scrollThreshold;

  @override
  State<BudgetGoalsListWidget> createState() => _BudgetGoalsListWidgetState();
}

class _BudgetGoalsListWidgetState extends State<BudgetGoalsListWidget> {
  @override
  Widget build(BuildContext context) => BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          // Handle pagination errors with snackbar
          if (state.hasPaginationError && state.hasData) {
            AppSnackBar.show(
              context: context,
              message: state.paginationError ?? '',
              actionLabel: 'Retry',
              onActionPressed: () =>
                  context.read<BudgetCubit>().retryPaginationRequest(),
            );
          }
          if (state.message != null &&
              state.message!.isNotEmpty &&
              (state.state == BudgetStates.loaded ||
                  state.state == BudgetStates.error)) {
            AppSnackBar.show(
              context: context,
              message: state.message!,
              type: state.state == BudgetStates.error
                  ? SnackBarType.error
                  : SnackBarType.success,
            );
          }
        },
        builder: (context, state) {
          // Initial loading state
          if (state.isInitialLoading) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
            );
          }
          if (state.hasError) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message ?? 'An error occurred',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                    const SizedBox(height: 12),
                    AppButton.icon(
                      text: 'Retry',
                      onPressed: () =>
                          context.read<BudgetCubit>().refreshBudgetGoals(),
                      leadingIcon: const Icon(Icons.refresh, size: 18),
                    ),
                  ],
                ),
              ),
            );
          }

          // No data state
          if (!state.hasData) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No budget goals yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first budget goal to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Build the budget goals list with additional states
          final budgetGoals = state.budgetGoals!.budgetGoals;

          return SliverMainAxisGroup(
            slivers: [
              // Main budget goals list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Check if we should trigger loading more
                      context.read<BudgetCubit>().checkAndLoadMore(
                            index,
                            threshold: widget.scrollThreshold,
                          );
                      final budgetGoal = budgetGoals[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BudgetGoalCard(
                          budgetGoal: budgetGoal,
                        ),
                      );
                    },
                    childCount: budgetGoals.length,
                  ),
                ),
              ),

              // Loading more indicator
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Pagination error indicator
              if (state.hasPaginationError && !state.isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.paginationError ?? 'An error occurred',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<BudgetCubit>()
                              .retryPaginationRequest(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // End of list indicator
              if (state.hasReachedMax &&
                  !state.hasPaginationError &&
                  budgetGoals.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'All budget goals loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
