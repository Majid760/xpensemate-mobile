import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budgets_list_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_pagination_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/usecases/create_expense_usecase.dart';
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
    this._createExpenseUseCase,
  ) : super(const ExpenseState()) {
    _pagingController.addListener(_showPaginationError);
    // Set the fetchPage function after initialization
    loadExpenseData(period: state.filterDefaultValue);
  }

  final GetExpensesUseCase _getExpensesUseCase;
  final GetExpenseStatsUseCase _getExpenseStatsUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final GetBudgetsUseCase _budgetsUseCase;
  final CreateExpensesUseCase _createExpenseUseCase;

  static const int _limit = 10;

  late final _pagingController = PagingController<int, ExpenseEntity>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async => fetchExpenses(pageKey),
  );
  PagingController<int, ExpenseEntity> get pagingController =>
      _pagingController;

  @override
  Future<void> close() async {
    _pagingController.dispose();
    return super.close();
  }

  /// Fetches expenses for a specific page
  Future<List<ExpenseEntity>> fetchExpenses(int pageKey) async {
    try {
      final params = GetExpensesParams(
        page: pageKey,
        limit: _limit,
      );
      final result = await _getExpensesUseCase(params);
      return result.fold(
        (failure) => [],
        (paginationEntity) => paginationEntity.expenses,
      );
    } on Exception catch (e, stackTrace) {
      debugPrint('getExpenses error: $e, stack: $stackTrace');
      return [];
    }
  }

  /// Load expense statistics
  Future<void> loadExpenseStats({required FilterDefaultValue period}) async {
    // Only show loading state if we don't have any existing data
    if (state.expenseStats == null) {
      emit(state.copyWith(state: ExpenseStates.loading));
    }

    final params = GetExpenseStatsParams(period: period.name);
    final result = await _getExpenseStatsUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          state: ExpenseStates.error,
          message: failure.message,
        ),
      ),
      (expenseStats) => emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          filterDefaultValue: period,
          expenseStats: expenseStats,
        ),
      ),
    );
  }

  /// Load all expense data with pagination support
  Future<void> loadExpenseData({FilterDefaultValue? period}) async {
    emit(state.copyWith(state: ExpenseStates.loading));

    try {
      // Load all data concurrently for better performance
      final expenseStatsFuture = _getExpenseStatsUseCase(
        GetExpenseStatsParams(period: period?.name),
      );
      final result = await expenseStatsFuture;
      result.fold(
        (failure) => emit(
          state.copyWith(
            state: ExpenseStates.error,
            message: failure.message,
          ),
        ),
        (expenseStats) => emit(
          state.copyWith(
            state: ExpenseStates.loaded,
            expenseStats: expenseStats,
          ),
        ),
      );
    } on Exception catch (e, s) {
      emit(
        state.copyWith(
          state: ExpenseStates.error,
          message: 'An unexpected error occurred: $e',
          stackTrace: s,
        ),
      );
    }
  }

  /// Update expense with optimistic updates and rollback on failure
  Future<void> updateExpense({required ExpenseEntity expense}) async {
    // Find the page and index of the expense to update
    final pages = _pagingController.value.pages ?? [];
    var pageIndex = -1;
    var itemIndex = -1;

    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      final index = page.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        pageIndex = i;
        itemIndex = index;
        break;
      }
    }
    // If found, update in the paging controller
    if (pageIndex != -1 && itemIndex != -1) {
      final updatedPages = List<List<ExpenseEntity>>.from(pages);
      final updatedPage = List<ExpenseEntity>.from(updatedPages[pageIndex]);
      updatedPage[itemIndex] = expense;
      updatedPages[pageIndex] = updatedPage;

      _pagingController.value = _pagingController.value.copyWith(
        pages: updatedPages,
      );
    }

    final result = await _updateExpenseUseCase(expense);
    await result.fold((failure) {
      // Refresh to rollback changes on failure
      _pagingController.refresh();
      emit(
        state.copyWith(
          state: ExpenseStates.error,
          message: failure.message,
        ),
      );
    }, (updatedExpense) async {
      // Recalculate stats after successful update
      unawaited(_recalculateExpenseStats());
      emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          message: 'Expense updated successfully!',
        ),
      );
    });
  }

  /// Create expense with optimistic updates
  Future<void> createExpense({required ExpenseEntity expense}) async {
    // Make the API call
    final result = await _createExpenseUseCase(
      CreateExpensesParams(expenseEntity: expense),
    );

    await result.fold(
      (failure) {
        // Refresh to rollback changes on failure
        _pagingController.refresh();
        emit(
          state.copyWith(
            state: ExpenseStates.error,
            message: failure.message,
            stackTrace: failure.stackTrace,
          ),
        );
      },
      (createdExpense) async {
        final pages = _pagingController.value.pages ?? [];
        final updatedPages = List<List<ExpenseEntity>>.from(pages);
        final firstPage = [expense, ...updatedPages[0]];
        updatedPages[0] = firstPage;

        _pagingController.value = _pagingController.value.copyWith(
          pages: updatedPages,
        );
        unawaited(_recalculateExpenseStats());
        emit(state.copyWith(state: ExpenseStates.loaded, message: ''));
      },
    );
  }

  /// Delete expense with optimistic updates and rollback on failure
  Future<void> deleteExpense({required String expenseId}) async {
    final result = await _deleteExpenseUseCase(expenseId);
    await result.fold(
      (failure) {
        // Refresh to rollback changes on failure
        _pagingController.refresh();
        emit(
          state.copyWith(
            state: ExpenseStates.error,
            message: failure.message,
          ),
        );
      },
      (success) async {
        // Remove from all pages
        final pages = _pagingController.value.pages ?? [];
        final updatedPages = <List<ExpenseEntity>>[];
        for (final page in pages) {
          final updatedPage = page.where((e) => e.id != expenseId).toList();
          updatedPages.add(updatedPage);
        }
        _pagingController.value = _pagingController.value.copyWith(
          pages: updatedPages,
        );
        unawaited(_recalculateExpenseStats());
        emit(state.copyWith(state: ExpenseStates.loaded));
      },
    );
  }

  Future<void> _recalculateExpenseStats() async {
    try {
      final result = await _getExpenseStatsUseCase(GetExpenseStatsParams());
      result.fold(
        (failure) {
          debugPrint('Failed to recalculate expense stats: ${failure.message}');
        },
        (expenseStats) {
          emit(state.copyWith(expenseStats: expenseStats));
        },
      );
    } on Exception catch (e) {
      debugPrint('Unexpected error while recalculating expense stats: $e');
    }
  }

  /// Load budgets
  Future<void> loadBudgets({
    String status = "active",
    int? page,
    int? limit,
  }) async {
    final params = GetBudgetsParams(status: status, page: page, limit: limit);

    final result = await _budgetsUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          state: ExpenseStates.error,
          message: failure.message,
        ),
      ),
      (success) => emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          budgets: success,
        ),
      ),
    );
  }

  void _showPaginationError() {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      emit(
        state.copyWith(
          state: ExpenseStates.error,
          message: 'Something went wrong while fetching expenses.',
        ),
      );
    }
  }

  /// Refresh expenses (reload from first page)
  Future<void> refreshExpenses() async {
    _pagingController.refresh();
  }
}

// Extension for easy access to cubit
extension ExpenseCubitX on BuildContext {
  ExpenseCubit get expenseCubit => read<ExpenseCubit>();
}
