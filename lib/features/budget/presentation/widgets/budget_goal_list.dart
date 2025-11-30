import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_expenses_page.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_form_page.dart';
import 'package:xpensemate/features/budget/presentation/widgets/budget_card_item.dart';
import 'package:xpensemate/features/budget/presentation/widgets/no_more_widget.dart';
import 'package:xpensemate/features/budget/presentation/widgets/retry_widget.dart';

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
        onSave: (goal) async {
          await context.budgetCubit.updateBudgetGoal(goal);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
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
        builder: (context, state) => PagingListener(
          controller: context.budgetCubit.pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedSliverList<int, BudgetGoalEntity>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<BudgetGoalEntity>(
              animateTransitions: true,
              invisibleItemsThreshold: 5,
              transitionDuration: const Duration(milliseconds: 300),
              itemBuilder: (context, budgetGoal, index) => BudgetGoalCard(
                budgetGoal: budgetGoal,
                onEdit: (goal) {
                  _editBudget(goal, context);
                },
                onDelete: (goalId) {
                  context.budgetCubit.deleteBudgetGoal(goalId);
                },
                onSelect: (selectedOption) {
                  if (selectedOption == 'edit') {
                    _editBudget(budgetGoal, context);
                  } else if (selectedOption == 'expenses') {
                    AppBottomSheet.showScrollable<void>(
                      context: context,
                      title: context.l10n.budget,
                      config: BottomSheetConfig(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sm,
                        ),
                        blurSigma: 5,
                        barrierColor:
                            context.theme.primaryColor.withValues(alpha: 0.4),
                      ),
                      child: ExpenseScreen(budgetGoal: budgetGoal),
                    );
                  } else if (selectedOption == 'delete') {
                    AppCustomDialogs.showDelete(
                      context: context,
                      title: context.l10n.delete,
                      message:
                          '${context.l10n.confirmDelete}\n\n${context.l10n.deleteWarning}',
                      onConfirm: () =>
                          context.budgetCubit.deleteBudgetGoal(budgetGoal.id),
                      onCancel: () {},
                    );
                  }
                },
              ),
              firstPageProgressIndicatorBuilder: (_) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
              firstPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
                errorMsg: state.error.toString(),
                onRetry: context.budgetCubit.pagingController.refresh,
              ),
              newPageErrorIndicatorBuilder: (_) => RetryWidget(
                onRetry: () => fetchNextPage,
                message: state.error.toString(),
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
              noMoreItemsIndicatorBuilder: (_) =>
                  const AllCaughtUpWidget(title: 'No more budgets!'),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
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
