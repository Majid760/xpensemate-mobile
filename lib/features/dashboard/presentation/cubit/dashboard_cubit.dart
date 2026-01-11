import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
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
    AppLogger.breadcrumb('Loading individual WeeklyStats...');
    if (state.weeklyStats == null) {
      emit(state.copyWith(state: DashboardStates.loading));
    }
    try {
      final result = await _getWeeklyStatsUseCase(const NoParams());
      result.fold(
        (failure) {
          AppLogger.breadcrumb('WeeklyStats failed: ${failure.message}');
          emit(
            state.copyWith(
              state: DashboardStates.error,
              message: failure.message,
            ),
          );
        },
        (weeklyStats) {
          AppLogger.breadcrumb('WeeklyStats loaded successfully');
          emit(
            state.copyWith(
              state: DashboardStates.loaded,
              weeklyStats: weeklyStats,
            ),
          );
        },
      );
    } on Exception catch (e, s) {
      AppLogger.e('loadWeeklyStats unexpected error', e, s);
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: e.toString(),
          stackTrace: s,
        ),
      );
    }
  }

  /// Load budget goals with optional parameters
  Future<void> loadBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    AppLogger.breadcrumb('Loading individual BudgetGoals...');
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

    try {
      final result = await _getBudgetGoalsUseCase(params);
      result.fold(
        (failure) {
          AppLogger.breadcrumb('BudgetGoals failed: ${failure.message}');
          emit(
            state.copyWith(
              state: DashboardStates.error,
              message: failure.message,
            ),
          );
        },
        (budgetGoals) {
          AppLogger.breadcrumb('BudgetGoals loaded successfully');
          emit(
            state.copyWith(
              state: DashboardStates.loaded,
              budgetGoals: budgetGoals,
            ),
          );
        },
      );
    } on Exception catch (e, s) {
      AppLogger.e('loadBudgetGoals unexpected error', e, s);
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: e.toString(),
          stackTrace: s,
        ),
      );
    }
  }

  /// Load product weekly analytics
  Future<void> loadProductAnalytics() async {
    AppLogger.breadcrumb('Loading individual ProductAnalytics...');
    // Only show loading state if we don't have any existing data
    if (state.productAnalytics == null) {
      emit(state.copyWith(state: DashboardStates.loading));
    }

    try {
      final result = await _getProductWeeklyAnalyticsUseCase(const NoParams());
      result.fold(
        (failure) {
          AppLogger.breadcrumb('ProductAnalytics failed: ${failure.message}');
          emit(
            state.copyWith(
              state: DashboardStates.error,
              message: failure.message,
            ),
          );
        },
        (productAnalytics) {
          AppLogger.breadcrumb('ProductAnalytics loaded successfully');
          emit(
            state.copyWith(
              state: DashboardStates.loaded,
              productAnalytics: productAnalytics,
            ),
          );
        },
      );
    } on Exception catch (e, s) {
      AppLogger.e('loadProductAnalytics unexpected error', e, s);
      emit(
        state.copyWith(
          state: DashboardStates.error,
          message: e.toString(),
          stackTrace: s,
        ),
      );
    }
  }

  /// Load all dashboard data
  Future<void> loadDashboardData({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    AppLogger.breadcrumb('Loading dashboard data (Bulk)...');
    AppLogger.setCustomKey('dashboard_fetch_status', 'loading');
    emit(state.copyWith(state: DashboardStates.loading));
    try {
      final results = await Future.wait([
        _getWeeklyStatsUseCase(const NoParams()),
        _getBudgetGoalsUseCase(
          GetBudgetGoalsParams(
            page: page,
            limit: limit,
            duration: duration,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
        _getProductWeeklyAnalyticsUseCase(const NoParams()),
      ]);

      final weeklyStatsResult =
          results[0] as Either<Failure, WeeklyStatsEntity>;
      final budgetGoalsResult =
          results[1] as Either<Failure, BudgetGoalsEntity>;
      final productAnalyticsResult =
          results[2] as Either<Failure, ProductWeeklyAnalyticsEntity>;

      var newWeeklyStats = state.weeklyStats;
      var newBudgetGoals = state.budgetGoals;
      var newProductAnalytics = state.productAnalytics;
      final errors = <String>[];

      weeklyStatsResult.fold(
        (l) => [
          errors.add(l.message),
          AppLogger.breadcrumb('WeeklyStats failed: ${l.message}'),
        ],
        (r) => newWeeklyStats = r,
      );

      budgetGoalsResult.fold(
        (l) => [
          errors.add(l.message),
          AppLogger.breadcrumb('BudgetGoals failed: ${l.message}'),
        ],
        (r) => newBudgetGoals = r,
      );

      productAnalyticsResult.fold(
        (l) => [
          errors.add(l.message),
          AppLogger.breadcrumb('ProductAnalytics failed: ${l.message}'),
        ],
        (r) => newProductAnalytics = r,
      );
      if (errors.length == 3) {
        // All failed
        AppLogger.setCustomKey('dashboard_fetch_status', 'failed');
        emit(
          state.copyWith(
            state: DashboardStates.error,
            message: errors.join('\n'),
          ),
        );
      } else {
        // Partial or full success
        AppLogger.setCustomKey('dashboard_fetch_status', 'success');
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            weeklyStats: newWeeklyStats,
            budgetGoals: newBudgetGoals,
            productAnalytics: newProductAnalytics,
            message: errors.isNotEmpty
                ? 'Some data failed to load: ${errors.join(", ")}'
                : null,
          ),
        );
      }
    } on Exception catch (e, s) {
      AppLogger.setCustomKey('dashboard_fetch_status', 'error');
      AppLogger.e('Dashboard data fetch failed (Fatal)', e, s);
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
    AppLogger.breadcrumb('Creating expense from Dashboard...');
    try {
      if (!_expenseCubit.isClosed) {
        await _expenseCubit.createExpense(expense: expense);
        AppLogger.breadcrumb('Expense created successfully (Dashboard)');
        loadDashboardData();
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            message: 'Expense created successfully!',
          ),
        );
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.e('createExpense from Dashboard failed', e, stackTrace);
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
    AppLogger.breadcrumb('Creating payment from Dashboard...');
    try {
      if (!_paymentCubit.isClosed) {
        await _paymentCubit.createPayment(payment: payment);
        AppLogger.breadcrumb('Payment created successfully (Dashboard)');
        unawaited(loadDashboardData());
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            message: 'Payment created successfully!',
          ),
        );
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.e('createPayment from Dashboard failed', e, stackTrace);
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
    AppLogger.breadcrumb('Creating budget from Dashboard...');
    try {
      if (!_budgetCubit.isClosed) {
        await _budgetCubit.createBudgetGoal(budget);
      }
      AppLogger.breadcrumb('Budget created successfully (Dashboard)');
      unawaited(loadDashboardData());
      emit(
        state.copyWith(
          state: DashboardStates.loaded,
          message: 'Budget created successfully!',
        ),
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.e('createBudget from Dashboard failed', e, stackTrace);
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
