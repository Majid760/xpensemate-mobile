import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_item_widget.dart';

class ExpenseListWidget extends StatelessWidget {
  const ExpenseListWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state.state == ExpenseStates.loading) {
            return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          if (state.state == ExpenseStates.error &&
              state.errorMessage != null &&
              state.expenses == null) {
            return SliverToBoxAdapter(
              child: ErrorStateSectionWidget(
                errorMsg: state.errorMessage,
                onRetry: () {
                  context.expenseCubit.loadExpenses();
                },
              ),
            );
          }

          if (state.expenses != null && state.expenses!.expenses.isNotEmpty) {
            final expenses = state.expenses!.expenses;
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = expenses[index];
                    return ExpenseListItem(
                      expense: expense,
                      isLast: index == expenses.length - 1,
                      onDelete: () {
                        // TODO: Implement delete functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Delete functionality to be implemented'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      onEdit: () {
                        // TODO: Implement edit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit functionality to be implemented'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    );
                  },
                  childCount: expenses.length,
                ),
              ),
            );
          }
          return SliverToBoxAdapter(
            child: Center(
              child: ErrorStateSectionWidget(
                errorMsg: state.errorMessage,
                onRetry: () {
                  context.expenseCubit.loadExpenses();
                },
              ),
            ),
          );
        },
      );
}