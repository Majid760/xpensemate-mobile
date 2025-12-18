import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_section_header.dart';
import 'package:xpensemate/core/widget/app_bar_widget.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_form_widget.dart';
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
        onSave: (expense) async {
          await context.expenseCubit.updateExpense(expense: expense);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ExpenseCubit, ExpenseState>(
        listenWhen: (previous, current) =>
            previous.message != current.message ||
            (current.expenseStats != previous.expenseStats),
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            AppSnackBar.show(
              context: context,
              message: state.message ?? "",
              type: state.state == ExpenseStates.error
                  ? SnackBarType.error
                  : SnackBarType.success,
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => _loadExpenseData(),
          color: Theme.of(context).primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BlocSelector<ExpenseCubit, ExpenseState, FilterValue>(
                selector: (state) => state.filterDefaultValue,
                builder: (context, filterDefaultValue) => CustomAppBar(
                  defaultPeriod: filterDefaultValue,
                  onChanged: (value) =>
                      context.expenseCubit.loadExpenseStats(period: value),
                ),
              ),
              BlocBuilder<ExpenseCubit, ExpenseState>(
                buildWhen: (previous, current) =>
                    previous.expenseStats != current.expenseStats ||
                    previous.filterDefaultValue != current.filterDefaultValue,
                builder: (context, state) => ExpenseStatsWidget(
                  stats: state.expenseStats,
                  filter: state.filterDefaultValue,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSectionHeader(
                    title: "Expenses",
                    icon: Icon(
                      Icons.receipt_long_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    onSearchChanged: (value) {
                      if (value.trim().isEmpty) return;
                      AppUtils.debounce(
                        () => context.expenseCubit.updateSearchTerm(value),
                        delay: const Duration(milliseconds: 700),
                      );
                    },
                    onSearchCleared: () =>
                        context.expenseCubit.refreshExpenses(),
                  ),
                ),
              ),

              // Keep ExpenseListWidget as is (assuming it returns a Sliver)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: ExpenseListWidget(
                  onEdit: (updatedEntity) {
                    _editExpense(updatedEntity, context);
                  },
                  onDelete: (expenseId) {
                    context.expenseCubit.deleteExpense(expenseId: expenseId);
                  },
                  scrollController: _scrollController,
                ),
              ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      );
}

// This function can be called from other pages or components
// to trigger the add expense action
void addExpense(
    {required BuildContext context, void Function(ExpenseEntity)? onSave}) {
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
      onSave: onSave ??
          (expense) async {
            if (!context.expenseCubit.isClosed) {
              await context.expenseCubit.createExpense(expense: expense);
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
      onCancel: () => Navigator.of(context).pop(),
    ),
  );
}
