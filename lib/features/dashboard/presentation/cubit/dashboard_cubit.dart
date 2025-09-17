import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budgets_list_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_budget_goals_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_budgets_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_product_weekly_analytics_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_weekly_stats_usecase.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._getWeeklyStatsUseCase,
    this._getBudgetGoalsUseCase,
    this._getProductWeeklyAnalyticsUseCase,
    this._getBudgetsUseCase,
  ) : super(const DashboardState()) {
    loadDashboardData();
  }

  final GetWeeklyStatsUseCase _getWeeklyStatsUseCase;
  final GetBudgetGoalsUseCase _getBudgetGoalsUseCase;
  final GetProductWeeklyAnalyticsUseCase _getProductWeeklyAnalyticsUseCase;
  final GetBudgetsUseCase _getBudgetsUseCase;

  /// Load weekly statistics
  Future<void> loadWeeklyStats() async {
    if (state.weeklyStats == null) {
      emit(state.copyWith(state: DashboardStates.loading));
    }
    final result = await _getWeeklyStatsUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: DashboardStates.error,
          errorMessage: failure.message,
        ),
      ),
      (weeklyStats) => emit(
        state.copyWith(
          state: DashboardStates.loaded,
          weeklyStats: weeklyStats,
        ),
      ),
    );
  }

  /// Load budget goals with optional parameters
  Future<void> loadBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.budgetGoals == null) {
      emit(state.copyWith(state: DashboardStates.loading));
    }
    final params = GetBudgetGoalsParams(
      page: page,
      limit: limit,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _getBudgetGoalsUseCase(params);
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: DashboardStates.error,
          errorMessage: failure.message,
        ),
      ),
      (budgetGoals) => emit(
        state.copyWith(
          state: DashboardStates.loaded,
          budgetGoals: budgetGoals,
        ),
      ),
    );
  }

  /// Load budgets with optional parameters
  Future<void> loadBudgets({
    int? page,
    int? limit,
    String? status,
  }) async {
    if (state.budgets == null) {
      emit(state.copyWith(state: DashboardStates.loading));
    }
    final params = GetBudgetsParams(
      page: page,
      limit: limit,
      status: status,
    );

    final result = await _getBudgetsUseCase(params);
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: DashboardStates.error,
          errorMessage: failure.message,
        ),
      ),
      (budgets) => emit(
        state.copyWith(
          state: DashboardStates.loaded,
          budgets: budgets,
        ),
      ),
    );
  }

  /// Load product weekly analytics
  Future<void> loadProductAnalytics() async {
    // Only show loading state if we don't have any existing data
    if (state.productAnalytics == null) {
      emit(state.copyWith(state: DashboardStates.loading));
    }

    final result = await _getProductWeeklyAnalyticsUseCase(const NoParams());
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            state: DashboardStates.error,
            errorMessage: failure.message,
          ),
        );
      },
      (productAnalytics) {
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            productAnalytics: productAnalytics,
          ),
        );
      },
    );
  }

  /// Load all dashboard data
  Future<void> loadDashboardData({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(state.copyWith(state: DashboardStates.loading));

    try {
      // Load all data concurrently for better performance
      final weeklyStatsFuture = _getWeeklyStatsUseCase(const NoParams());
      final budgetGoalsFuture = _getBudgetGoalsUseCase(
        GetBudgetGoalsParams(
          page: page,
          limit: limit,
          duration: duration,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      final budgetsFuture = _getBudgetsUseCase(
        GetBudgetsParams(
          page: page,
          limit: limit,
        ),
      );
      final productAnalyticsFuture =
          _getProductWeeklyAnalyticsUseCase(const NoParams());

      final results = await Future.wait([
        weeklyStatsFuture,
        budgetGoalsFuture,
        budgetsFuture,
        productAnalyticsFuture,
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
            state: DashboardStates.error,
            errorMessage: failures.first,
          ),
        );
      } else {
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            weeklyStats: data[0] as WeeklyStatsEntity,
            budgetGoals: data[1] as BudgetGoalsEntity,
            budgets: data[2] as BudgetsListEntity,
            productAnalytics: data[3] as ProductWeeklyAnalyticsEntity,
          ),
        );
      }
    } on Exception catch (e, s) {
      emit(
        state.copyWith(
          state: DashboardStates.error,
          errorMessage: 'An unexpected error occurred: $e',
          stackTrace: s,
        ),
      );
    }
  }
}
