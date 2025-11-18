import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_form_page.dart';
import 'package:xpensemate/features/budget/presentation/widgets/budget_card_item.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class BudgetGoalsListWidget extends StatefulWidget {
  const BudgetGoalsListWidget({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  State<BudgetGoalsListWidget> createState() => _BudgetGoalsListWidgetState();
}

class _BudgetGoalsListWidgetState extends State<BudgetGoalsListWidget> {
  PagingState<int, BudgetGoalEntity> _pagingState = PagingState();

  Future<void> _fetchNextPage() async {
    if (_pagingState.isLoading) return;

    setState(() {
      _pagingState = _pagingState.copyWith(isLoading: true, error: null);
    });

    try {
      final pageKey = (_pagingState.keys?.last ?? 0) + 1;
      await context.read<BudgetCubit>().getBudgetGoals(page: pageKey);
    } on Exception catch (error) {
      setState(() {
        _pagingState = _pagingState.copyWith(
          error: error,
          isLoading: false,
        );
      });
    }
  }

  void _editBudget(BudgetGoalEntity? budget, BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      title: "Edit Budget",
      config: const BottomSheetConfig(
        padding: EdgeInsets.symmetric(horizontal: 8),
        blurSigma: 5,
        barrierColor: Colors.transparent,
      ),
      child: BudgetFormPage(
        budget: budget,
        onSave: (goal) {
          context.budgetCubit.updateBudgetGoal(goal);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          // Handle state updates for pagination
          if (state.state == BudgetStates.loaded) {
            if (state.budgetGoals != null) {
              final pageKey = state.budgetGoals!.page;
              final isLastPage = state.hasReachedMax;
              final items = state.budgetGoals!.budgetGoals;

              setState(() {
                if (pageKey == 1) {
                  // First page - replace the first page with updated data
                  // If we already have pages, update the first one, otherwise set it
                  if (_pagingState.keys != null &&
                      _pagingState.keys!.isNotEmpty) {
                    // Update the first page with the new data
                    final updatedPages = [...?_pagingState.pages];
                    if (updatedPages.isNotEmpty) {
                      updatedPages[0] = items;
                    } else {
                      updatedPages.add(items);
                    }

                    _pagingState = _pagingState.copyWith(
                      pages: updatedPages,
                      hasNextPage: !isLastPage,
                      isLoading: false,
                    );
                  } else {
                    // First time loading
                    _pagingState = _pagingState.copyWith(
                      pages: [items],
                      keys: [pageKey],
                      hasNextPage: !isLastPage,
                      isLoading: false,
                    );
                  }
                } else {
                  // Append page
                  _pagingState = _pagingState.copyWith(
                    pages: [...?_pagingState.pages, items],
                    keys: [...?_pagingState.keys, pageKey],
                    hasNextPage: !isLastPage,
                    isLoading: false,
                  );
                }
              });
            }
          } else if (state.state == BudgetStates.error) {
            setState(() {
              _pagingState = _pagingState.copyWith(
                error: state.message,
                isLoading: false,
              );
            });
          }

          // Handle general messages
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
          final localizations = AppLocalizations.of(context);

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
              child: ErrorStateSectionWidget(
                errorMsg: state.message,
                onRetry: () => context.read<BudgetCubit>().refreshBudgetGoals(),
              ),
            );
          }

          // No data state
          if (!state.hasData) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.noDataAvailable,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      AppButton.icon(
                        onPressed: () {
                          context.read<BudgetCubit>().refreshBudgetGoals();
                        },
                        leadingIcon: const Icon(Icons.refresh),
                        text: context.l10n.tryAgain,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: PagedSliverList<int, BudgetGoalEntity>.separated(
              state: _pagingState,
              fetchNextPage: _fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<BudgetGoalEntity>(
                  itemBuilder: (context, budgetGoal, index) => BudgetGoalCard(
                        budgetGoal: budgetGoal,
                        onEdit: (goal) {
                          _editBudget(goal, context);
                        },
                        onDelete: (goalId) {
                          context.budgetCubit.deleteBudgetGoal(goalId);
                        },
                      ),
                  firstPageProgressIndicatorBuilder: (_) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                  firstPageErrorIndicatorBuilder: (_) =>
                      ErrorStateSectionWidget(
                        errorMsg: _pagingState.error?.toString(),
                        onRetry: _fetchNextPage,
                      ),
                  newPageErrorIndicatorBuilder: (_) => Padding(
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
                              localizations?.budgetGoalsError ??
                                  'An error occurred',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _fetchNextPage,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(
                                  localizations?.budgetGoalsRetry ?? 'Retry'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.noDataAvailable,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                  noMoreItemsIndicatorBuilder: (_) {
                    print('yes enter in no more');
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No more budget goals',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    );
                  }),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          );
        },
      );
}

// This function can be called from other pages or components
// to trigger the add budget action
void addBudget(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  AppBottomSheet.show<void>(
    context: context,
    title: 'Add Budget',
    config: BottomSheetConfig(
      minHeight: screenHeight * 0.8,
      maxHeight: screenHeight * 0.95,
      padding: EdgeInsets.zero,
      blurSigma: 5,
      barrierColor: Colors.transparent,
    ),
    child: BudgetFormPage(
      onSave: (goal) async {
        await context.budgetCubit.createBudgetGoal(goal);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      onCancel: () => Navigator.of(context).pop(),
    ),
  );
}
