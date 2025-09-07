import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_expense_stats_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_expenses_usecase.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit(
    this._getExpensesUseCase,
    this._getExpenseStatsUseCase,
  ) : super(const ExpenseState()) {
    loadExpenseData();
  }

  final GetExpensesUseCase _getExpensesUseCase;
  final GetExpenseStatsUseCase _getExpenseStatsUseCase;

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
      ),
      (expenseStats) => emit(
        state.copyWith(
          state: ExpenseStates.loaded,
          expenseStats: expenseStats,
        ),
      ),
    );
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
        print('error 1 => ${failures[0].toString()}');

        emit(
          state.copyWith(
            state: ExpenseStates.error,
            errorMessage: failures.first,
          ),
        );
      } else {
        print(
            " stats data is ${(data[1] as ExpenseStatsEntity).categories.length}");
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
}
