import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/budget/presentation/widgets/no_more_widget.dart';
import 'package:xpensemate/features/budget/presentation/widgets/retry_widget.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_item_widget.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          // Handle general messages
          if (state.message != null && state.message!.isNotEmpty) {
            AppSnackBar.show(
              context: context,
              message: state.message!,
              type: state.state == ExpenseStates.error
                  ? SnackBarType.error
                  : SnackBarType.success,
            );
          }
        },
        builder: (context, state) => PagingListener(
          controller: context.expenseCubit.pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedSliverList<int, ExpenseEntity>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<ExpenseEntity>(
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 400),
              itemBuilder: (context, expense, index) => ExpenseListItem(
                expense: expense,
                onDelete: widget.onDelete,
                onEdit: widget.onEdit,
              ),
              firstPageProgressIndicatorBuilder: (_) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
              newPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
              firstPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
                errorMsg:
                    (state.error ?? 'Error while loading expenses!').toString(),
                onRetry: context.expenseCubit.pagingController.refresh,
              ),
              newPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
                onRetry: () => fetchNextPage,
                errorMsg:
                    (state.error ?? 'Error while loading expenses!').toString(),
              ),
              noMoreItemsIndicatorBuilder: (_) =>
                  const AllCaughtUpWidget(title: 'No more expenses!'),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 4),
          ),
        ),
      );
}
