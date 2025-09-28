import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_custom_dropdown_widget.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_form_widget.dart';
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
    context.expenseCubit.loadBudgets();
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

  void _editExpense(ExpenseEntity entity, BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      title: "Edit Expense",
      config: const BottomSheetConfig(
        padding: EdgeInsets.symmetric(horizontal: 8),
        blurSigma: 5,
        barrierColor: Colors.transparent,
      ),
      child: ExpenseFormWidget(
        expense: entity,
        onSave: (expense) {
          context.expenseCubit.updateExpense(expense: expense).then((value) {
            if (context.mounted) {
              AppSnackBar.show(
                context: context,
                message: 'Expense updated successfully',
                type: SnackBarType.success,
              );
              Navigator.pop(context);
            }
          });
        },
      ),
    );
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
                    onEdit: (updatedEntity) {
                      _editExpense(updatedEntity, context);
                    },
                    onDelete: (expenseId) {
                      context.expenseCubit.deleteExpense(expenseId: expenseId);
                    },
                    scrollController: _scrollController,
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

// This function can be called from other pages or components
// to trigger the add expense action
void addExpense(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  AppBottomSheet.show<void>(
    context: context,
    title: 'Add Expense',
    config: BottomSheetConfig(
      minHeight: screenHeight * 0.8,
      maxHeight: screenHeight * 0.95,
      padding: EdgeInsets.zero,
      blurSigma: 5,
      barrierColor: Colors.transparent,
    ),
    child: ExpenseFormWidget(
      onSave: (expense) {
        Navigator.of(context).pop();
        context.expenseCubit.createExpense(expense: expense).then((value) {
          if (context.mounted) {
            AppSnackBar.show(
              context: context,
              message: 'Expense added successfully',
              type: SnackBarType.success,
            );
          }
        });
      },
      onCancel: () => Navigator.of(context).pop(),
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
