import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_pagination_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_budgets_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_expense_stats_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/update_expense_usecase.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit(
    this._getExpensesUseCase,
    this._getExpenseStatsUseCase,
    this._deleteExpenseUseCase,
    this._updateExpenseUseCase,
    this._budgetsUseCase,
  ) : super(const ExpenseState()) {
    loadExpenseData();
  }

  final GetExpensesUseCase _getExpensesUseCase;
  final GetExpenseStatsUseCase _getExpenseStatsUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final GetBudgetsUseCase _budgetsUseCase;

  /// Load expenses with pagination (matches web app: /expenses?page=${page}&limit=${limit})
  Future<void> loadExpenses({
    int page = 1,
    int limit = 10,
  }) async {
    // Only show loading state if we don't have any existing data
    if (state.expenses == null) {
      emit(state.copyWith(state: ExpenseStates.loading));
    }

    final params = GetExpensesParams(
      page: page,
      limit: limit,
    );

    final result = await _getExpensesUseCase(params);
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: failure.message,
        ),
      ),
      (expenses) => emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          expenses: expenses,
        ),
      ),
    );
  }

  /// Load expense statistics
  Future<void> loadExpenseStats({
    String? period,
  }) async {
    // Only show loading state if we don't have any existing data
    if (state.expenseStats == null) {
      emit(state.copyWith(state: ExpenseStates.loading));
    }
    final params = GetExpenseStatsParams(
      period: period,
    );

    final result = await _getExpenseStatsUseCase(params);
    result.fold(
        (failure) => emit(
              state.copyWith(
                state: ExpenseStates.error,
                errorMessage: failure.message,
              ),
            ), (expenseStats) {
      print("expenseStats: ${expenseStats.dailyAverage}");
      emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          expenseStats: expenseStats,
        ),
      );
    });
  }

  /// Load all expense data
  Future<void> loadExpenseData({
    int page = 1,
    int limit = 10,
    String? period,
  }) async {
    emit(state.copyWith(state: ExpenseStates.loading));

    try {
      // Load all data concurrently for better performance
      final expensesFuture = _getExpensesUseCase(
        GetExpensesParams(
          page: page,
          limit: limit,
        ),
      );

      final expenseStatsFuture = _getExpenseStatsUseCase(
        GetExpenseStatsParams(
          period: period,
        ),
      );

      final results = await Future.wait([
        expensesFuture,
        expenseStatsFuture,
      ]);

      final failures = <String>[];
      final data = <dynamic>[];
      for (final result in results) {
        result.fold(
          (failure) => failures.add(failure.message),
          data.add,
        );
      }
      if (failures.isNotEmpty) {
        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failures.first,
          ),
        );
      } else {
        emit(
          state.copyWith(
            state: ExpenseStates.loaded,
            expenses: data[0] as ExpensePaginationEntity,
            expenseStats: data[1] as ExpenseStatsEntity,
          ),
        );
      }
    } on Exception catch (e, s) {
      emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: 'An unexpected error occurred: $e',
          stackTrace: s,
        ),
      );
    }
  }

  // delete expense
  Future<void> deleteExpense({required String expenseId}) async {
    final originalExpenses = state.expenses;

    if (state.expenses != null) {
      final updatedExpenses = state.expenses!.expenses
          .where((expense) => expense.id != expenseId)
          .toList();

      final updatedPagination = state.expenses!.copyWith(
        expenses: updatedExpenses,
        total: state.expenses!.total - 1,
      );
      emit(state.copyWith(expenses: updatedPagination));
    }
    final result = await _deleteExpenseUseCase(expenseId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: failure.message,
          expenses: originalExpenses,
        ),
      ),
      (success) => emit(
        state.copyWith(state: ExpenseStates.loaded),
      ),
    );
  }

  // update expense
  Future<void> updateExpense({required ExpenseEntity expense}) async {
    final originalExpenses = state.expenses;
    if (state.expenses != null) {
      final updatedExpenses = state.expenses!.expenses
          .map((e) => e.id == expense.id ? expense : e)
          .toList();
      final updatedPagination = state.expenses!.copyWith(
        expenses: updatedExpenses,
      );
      emit(state.copyWith(expenses: updatedPagination));
    }

    final result = await _updateExpenseUseCase(expense);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failure.message,
            expenses: originalExpenses,
          ),
        );
      },
      (updatedExpense) {
        emit(
          state.copyWith(
            state: ExpenseStates.loaded,
          ),
        );
      },
    );
  }

  // create expense
  Future<void> createExpense({required ExpenseEntity expense}) async {
    // Then make the remote call
    final result = await _updateExpenseUseCase(expense);
    result.fold(
      (failure) {
        // If the remote call fails, emit an error state
        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failure.message,
          ),
        );
      },
      (createdExpense) {
        // If successful, reload the expenses to include the new one
        // Add a small delay to allow for smooth transition
        Future.delayed(const Duration(milliseconds: 100), () {
          loadExpenses();
        });
      },
    );
  }

  // load the budgets
  Future<void> loadBudgets(
      {String status = "active", int? page, int? limit}) async {
    final params = GetBudgetsParams(
      status: status,
      page: page,
      limit: limit,
    );
    final result = await _budgetsUseCase(params);
    result.fold((failure) {
      emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: failure.message,
        ),
      );
    }, (success) {
      print("thi is page list offofofofoof => ${success.budgets.length}");
    });
  }
}

// extension of expense cubit on context

extension ExpenseCubitX on BuildContext {
  ExpenseCubit get expenseCubit => read<ExpenseCubit>();
}
