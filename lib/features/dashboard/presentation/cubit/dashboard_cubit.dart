import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_budget_goals_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_product_weekly_analytics_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_weekly_stats_usecase.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._getWeeklyStatsUseCase,
    this._getBudgetGoalsUseCase,
    this._getProductWeeklyAnalyticsUseCase,
    this._expenseCubit,
    this._paymentCubit,
    this._budgetCubit,
  ) : super(const DashboardState()) {
    loadDashboardData();
    loadProductAnalytics();
  }

  final GetWeeklyStatsUseCase _getWeeklyStatsUseCase;
  final GetBudgetGoalsUseCase _getBudgetGoalsUseCase;
  final GetProductWeeklyAnalyticsUseCase _getProductWeeklyAnalyticsUseCase;
  final ExpenseCubit _expenseCubit;
  final PaymentCubit _paymentCubit;
  final BudgetCubit _budgetCubit;

  @override
  void onChange(Change<DashboardState> change) {
    super.onChange(change);
    if (change.currentState.state == DashboardStates.loaded) {
      // AnalyticsService().logEvent(
      //   name: 'dashboard_loaded',
      //   parameters: {
      //     'weekly_stats': change.currentState.weeklyStats,
      //     'budget_goals': change.currentState.budgetGoals,
      //     'product_analytics': change.currentState.productAnalytics,
      //   },
      // );
    }
  }

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
          message: failure.message,
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
          message: failure.message,
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
            message: failure.message,
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
      final productAnalyticsFuture =
          _getProductWeeklyAnalyticsUseCase(const NoParams());

      final results = await Future.wait([
        weeklyStatsFuture,
        budgetGoalsFuture,
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
            message: failures.first,
          ),
        );
      } else {
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            weeklyStats: data[0] as WeeklyStatsEntity,
            budgetGoals: data[1] as BudgetGoalsEntity,
            productAnalytics: data[2] as ProductWeeklyAnalyticsEntity,
          ),
        );
      }
    } on Exception catch (e, s) {
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: 'An unexpected error occurred: $e',
          stackTrace: s,
        ),
      );
    }
  }

  // add expense
  Future<void> createExpense({required ExpenseEntity expense}) async {
    try {
      if (!_expenseCubit.isClosed) {
        await _expenseCubit.createExpense(expense: expense);
        unawaited(loadDashboardData());
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            message: 'Expense created successfully!',
          ),
        );
      }
    } on Exception catch (e, stackTrace) {
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: 'An unexpected error occurred while creating expense: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // add payment
  Future<void> createPayment({required PaymentEntity payment}) async {
    try {
      if (!_paymentCubit.isClosed) {
        await _paymentCubit.createPayment(payment: payment);
        unawaited(loadDashboardData());
        emit(state.copyWith(
          state: DashboardStates.loaded,
          message: 'Payment created successfully!',
        ));
      }
    } on Exception catch (e, stackTrace) {
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: 'An unexpected error occurred while creating payment: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // add budget
  Future<void> createBudget({required BudgetGoalEntity budget}) async {
    try {
      if (!_budgetCubit.isClosed) {
        await _budgetCubit.createBudgetGoal(budget);
      }
      unawaited(loadDashboardData());
      emit(
        state.copyWith(
          state: DashboardStates.loaded,
          message: 'Budget created successfully!',
        ),
      );
    } on Exception catch (e, stackTrace) {
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: 'An unexpected error occurred while creating budget: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

extension DashboardCubitX on BuildContext {
  DashboardCubit get dashboardCubit => read<DashboardCubit>();
}
