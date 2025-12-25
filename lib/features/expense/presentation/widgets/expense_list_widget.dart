import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/budget/presentation/widgets/no_more_widget.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_card_widget.dart';
import 'package:xpensemate/core/widget/custom_app_loader.dart';

class ExpenseListWidget extends StatefulWidget {
  const ExpenseListWidget({
    super.key,
    this.onDelete,
    this.onEdit,
    this.scrollController,
  });

  final void Function(String expenseId)? onDelete;
  final void Function(ExpenseEntity expenseEntity)? onEdit;
  final ScrollController? scrollController;

  @override
  State<ExpenseListWidget> createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget> {
  bool _shouldAnimate = true;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _shouldAnimate = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PagingListener(
        controller: context.expenseCubit.pagingController,
        builder: (context, pagingState, fetchNextPage) =>
            PagedSliverList<int, ExpenseEntity>(
          state: pagingState,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<ExpenseEntity>(
            animateTransitions: true,
            transitionDuration: const Duration(milliseconds: 400),
            itemBuilder: (context, expense, index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ExpenseCardWidget(
                key: ValueKey(expense.id),
                shouldAnimate: _shouldAnimate,
                expense: expense,
                onDelete: widget.onDelete,
                onEdit: widget.onEdit,
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => ErrorStateSectionWidget(
              onRetry: () => context.expenseCubit.pagingController.refresh(),
              errorMsg: 'No Expense found!',
            ),
            firstPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CustomAppLoader()),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CustomAppLoader(),
              ),
            ),
            firstPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
              errorMsg: (context.expenseCubit.pagingController.error ??
                      'Error while loading expenses!')
                  .toString(),
              onRetry: context.expenseCubit.pagingController.refresh,
            ),
            newPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
              onRetry: () =>
                  context.expenseCubit.pagingController.fetchNextPage(),
              errorMsg: (context.expenseCubit.pagingController.error ??
                      'Error while loading expenses!')
                  .toString(),
            ),
            noMoreItemsIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.only(top: 32),
              child: AllCaughtUpWidget(title: 'No more expenses!'),
            ),
          ),
        ),
      );
}
