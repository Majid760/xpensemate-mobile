import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    loadExpenseData();
  }

  final GetExpensesUseCase _getExpensesUseCase;
  final GetExpenseStatsUseCase _getExpenseStatsUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final GetBudgetsUseCase _budgetsUseCase;
  final CreateExpensesUseCase _createExpenseUseCase;

  // Pagination state management
  final List<ExpenseEntity> _allExpenses = [];
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;
  int _defaultLimit = 10;

  /// Load expenses with pagination support and infinite scroll logic
  Future<void> loadExpenses({
    int page = 1,
    int limit = 10,
    bool refresh = false,
    bool loadMore = false,
  }) async {
    try {
      // Prevent multiple concurrent requests for pagination
      if (_isLoadingMore && loadMore) return;
      if (_hasReachedMax && loadMore) return;

      // Handle refresh - reset pagination state
      if (refresh || page == 1) {
        _resetPaginationState();
        emit(
          state.copyWith(
            state: ExpenseStates.loading,
          ),
        );
      } else if (loadMore) {
        // Loading more items
        _isLoadingMore = true;
        emit(
          state.copyWith(
            state: ExpenseStates.loadingMore,
            isLoadingMore: true,
          ),
        );
      } else if (state.expenses == null) {
        // Initial load
        emit(state.copyWith(state: ExpenseStates.loading));
      }

      _currentPage = page;
      _defaultLimit = limit;

      final params = GetExpensesParams(
        page: page,
        limit: limit,
      );

      final result = await _getExpensesUseCase(params);

      result.fold(
        (failure) => _handleExpenseLoadFailure(failure.message, page, loadMore),
        (paginationEntity) => _handleExpenseLoadSuccess(
          paginationEntity,
          page,
          refresh || page == 1,
        ),
      );
    } on Exception catch (e, stackTrace) {
      _handleExpenseLoadFailure(
        'Unexpected error: $e',
        page,
        loadMore,
        stackTrace,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Handle successful expense loading with pagination logic
  void _handleExpenseLoadSuccess(
    ExpensePaginationEntity paginationEntity,
    int page,
    bool isFirstPageOrRefresh,
  ) {
    final newExpenses = paginationEntity.expenses;

    if (isFirstPageOrRefresh) {
      // First page or refresh - replace all expenses
      _allExpenses.clear();
      _allExpenses.addAll(newExpenses);
    } else {
      // Subsequent pages - append new expenses, avoiding duplicates
      final uniqueNewExpenses = newExpenses.where(
        (newExpense) =>
            !_allExpenses.any((existing) => existing.id == newExpense.id),
      );
      _allExpenses.addAll(uniqueNewExpenses);
    }

    // Determine if we've reached the maximum
    _hasReachedMax = _currentPage >= paginationEntity.totalPages ||
        newExpenses.isEmpty ||
        newExpenses.length < _defaultLimit;

    // Create updated pagination entity with all loaded expenses
    final updatedPaginationEntity = ExpensePaginationEntity(
      page: _currentPage,
      totalPages: paginationEntity.totalPages,
      expenses: List.from(_allExpenses),
      total: paginationEntity.total,
    );

    emit(
      state.copyWith(
        state: ExpenseStates.loaded,
        expenses: updatedPaginationEntity,
        currentPage: _currentPage,
        hasReachedMax: _hasReachedMax,
        isLoadingMore: false,
      ),
    );
  }

  /// Handle expense loading failure with appropriate error states
  void _handleExpenseLoadFailure(
    String errorMessage,
    int page,
    bool isLoadMore, [
    StackTrace? stackTrace,
  ]) {
    if (page == 1 || !isLoadMore) {
      // First page error - show main error state
      emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: errorMessage,
          stackTrace: stackTrace,
          isLoadingMore: false,
        ),
      );
    } else {
      // Pagination error - keep existing data, show pagination error
      emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          paginationError: errorMessage,
          isLoadingMore: false,
        ),
      );
    }
  }

  /// Load next page for infinite scroll
  Future<void> loadNextPage() async {
    if (_hasReachedMax || _isLoadingMore) return;

    await loadExpenses(
      page: _currentPage + 1,
      limit: _defaultLimit,
      loadMore: true,
    );
  }

  /// Refresh expenses (reload from first page)
  Future<void> refreshExpenses({int limit = 10}) async {
    await loadExpenses(
      limit: limit,
      refresh: true,
    );
  }

  /// Check if should load more items (for infinite scroll trigger)
  bool shouldLoadMore(int currentIndex, {int threshold = 5}) {
    if (_hasReachedMax || _isLoadingMore) return false;

    final totalLoaded = _allExpenses.length;
    return currentIndex >= totalLoaded - threshold && totalLoaded > 0;
  }

  /// Trigger load more if conditions are met
  void checkAndLoadMore(int currentIndex, {int threshold = 5}) {
    if (shouldLoadMore(currentIndex, threshold: threshold)) {
      loadNextPage();
    }
  }

  /// Load expense statistics
  Future<void> loadExpenseStats({String? period}) async {
    // Only show loading state if we don't have any existing data
    if (state.expenseStats == null) {
      emit(state.copyWith(state: ExpenseStates.loading));
    }

    final params = GetExpenseStatsParams(period: period);
    final result = await _getExpenseStatsUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: failure.message,
        ),
      ),
      (expenseStats) => emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          expenseStats: expenseStats,
        ),
      ),
    );
  }

  /// Load all expense data with pagination support
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

      final results = await Future.wait([expensesFuture, expenseStatsFuture]);

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
        final paginationEntity = data[0] as ExpensePaginationEntity;

        // Initialize pagination state
        _resetPaginationState();
        _allExpenses.addAll(paginationEntity.expenses);
        _currentPage = page;
        _hasReachedMax = page >= paginationEntity.totalPages ||
            paginationEntity.expenses.length < limit;

        emit(
          state.copyWith(
            state: ExpenseStates.loaded,
            expenses: paginationEntity,
            expenseStats: data[1] as ExpenseStatsEntity,
            currentPage: _currentPage,
            hasReachedMax: _hasReachedMax,
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

  /// Delete expense with optimistic updates and rollback on failure
  Future<void> deleteExpense({required String expenseId}) async {
    final originalExpenses = state.expenses;
    final originalAllExpenses = List<ExpenseEntity>.from(_allExpenses);

    // Optimistic update - remove from both local cache and state
    _allExpenses.removeWhere((expense) => expense.id == expenseId);

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

    // Make the API call
    final result = await _deleteExpenseUseCase(expenseId);

    result.fold(
      (failure) {
        // Rollback on failure
        _allExpenses.clear();
        _allExpenses.addAll(originalAllExpenses);

        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failure.message,
            expenses: originalExpenses,
          ),
        );
      },
      (success) => emit(state.copyWith(state: ExpenseStates.loaded)),
    );
  }

  /// Update expense with optimistic updates and rollback on failure
  Future<void> updateExpense({required ExpenseEntity expense}) async {
    final originalExpenses = state.expenses;
    final originalAllExpenses = List<ExpenseEntity>.from(_allExpenses);

    // Optimistic update - update in both local cache and state
    final cacheIndex = _allExpenses.indexWhere((e) => e.id == expense.id);
    if (cacheIndex != -1) {
      _allExpenses[cacheIndex] = expense;
    }

    if (state.expenses != null) {
      final updatedExpenses = state.expenses!.expenses
          .map((e) => e.id == expense.id ? expense : e)
          .toList();

      final updatedPagination =
          state.expenses!.copyWith(expenses: updatedExpenses);
      emit(state.copyWith(expenses: updatedPagination));
    }

    // Make the API call
    final result = await _updateExpenseUseCase(expense);

    result.fold(
      (failure) {
        // Rollback on failure
        _allExpenses.clear();
        _allExpenses.addAll(originalAllExpenses);

        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failure.message,
            expenses: originalExpenses,
          ),
        );
      },
      (updatedExpense) => emit(state.copyWith(state: ExpenseStates.loaded)),
    );
  }

  /// Create expense with optimistic updates
  Future<void> createExpense({required ExpenseEntity expense}) async {
    // Optimistic update - add to beginning of both cache and state
    _allExpenses.insert(0, expense);

    final updatedPagination = ExpensePaginationEntity(
      page: state.expenses?.page ?? 1,
      totalPages: state.expenses?.totalPages ?? 1,
      expenses: [expense, ...?state.expenses?.expenses],
      total: (state.expenses?.total ?? 0) + 1,
    );

    emit(state.copyWith(expenses: updatedPagination));

    // Make the API call
    final result = await _createExpenseUseCase(
      CreateExpensesParams(expenseEntity: expense),
    );

    result.fold(
      (failure) {
        // Remove the optimistically added item on failure
        _allExpenses.removeWhere((e) => e.id == expense.id);

        final rollbackPagination = ExpensePaginationEntity(
          page: state.expenses?.page ?? 1,
          totalPages: state.expenses?.totalPages ?? 1,
          expenses: _allExpenses,
          total: (state.expenses?.total ?? 1) - 1,
        );

        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failure.message,
            expenses: rollbackPagination,
          ),
        );
      },
      (createdExpense) {
        // Replace optimistic item with actual created item
        final index = _allExpenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _allExpenses[index] = expense;
        }

        emit(state.copyWith(state: ExpenseStates.loaded));
      },
    );
  }

  /// Load budgets
  Future<void> loadBudgets({
    String status = "active",
    int? page,
    int? limit,
  }) async {
    final params = GetBudgetsParams(
      status: status,
      page: page,
      limit: limit,
    );

    final result = await _budgetsUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          state: ExpenseStates.error,
          errorMessage: failure.message,
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

  /// Reset pagination state
  void _resetPaginationState() {
    _allExpenses.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
  }

  /// Retry last failed pagination request
  void retryPaginationRequest() {
    if (state.paginationError != null) {
      loadNextPage();
    } else if (state.state == ExpenseStates.error) {
      refreshExpenses();
    }
  }

  // Getters for pagination state
  bool get hasReachedMax => _hasReachedMax;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get totalItemsLoaded => _allExpenses.length;
  List<ExpenseEntity> get allLoadedExpenses => List.unmodifiable(_allExpenses);
}

// Extension for easy access to cubit
extension ExpenseCubitX on BuildContext {
  ExpenseCubit get expenseCubit => read<ExpenseCubit>();
}
