import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_budget_goals_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_weekly_stats_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_product_weekly_analytics_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_product_weekly_analytics_for_category_usecase.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._getWeeklyStatsUseCase,
    this._getBudgetGoalsUseCase,
    this._getProductWeeklyAnalyticsUseCase,
    this._getProductWeeklyAnalyticsForCategoryUseCase,
  ) : super(const DashboardState()) {
    loadDashboardData();
  }

  final GetWeeklyStatsUseCase _getWeeklyStatsUseCase;
  final GetBudgetGoalsUseCase _getBudgetGoalsUseCase;
  final GetProductWeeklyAnalyticsUseCase _getProductWeeklyAnalyticsUseCase;
  final GetProductWeeklyAnalyticsForCategoryUseCase _getProductWeeklyAnalyticsForCategoryUseCase;

  /// Load weekly statistics
  Future<void> loadWeeklyStats() async {
    emit(state.copyWith(state: DashboardStates.loading));

    final result = await _getWeeklyStatsUseCase(const NoParams());
    result.fold(
        (failure) => emit(state.copyWith(
              state: DashboardStates.error,
              errorMessage: failure.message,
            )), (weeklyStats) {
      print('Weekly Stats: ${weeklyStats.toString()}');
      emit(
        state.copyWith(
          state: DashboardStates.loaded,
          weeklyStats: weeklyStats,
        ),
      );
    });
  }

  /// Load budget goals with optional parameters
  Future<void> loadBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(state.copyWith(state: DashboardStates.loading));

    final params = GetBudgetGoalsParams(
      page: page,
      limit: limit,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _getBudgetGoalsUseCase(params);
    result.fold(
      (failure) => emit(state.copyWith(
        state: DashboardStates.error,
        errorMessage: failure.message,
      )),
      (budgetGoals) {
        print('Budget Goals: ${budgetGoals.toString()}');
        emit(
          state.copyWith(
            state: DashboardStates.loaded,
            budgetGoals: budgetGoals,
          ),
        );
      },
    );
  }

  /// Load product weekly analytics
  Future<void> loadProductAnalytics() async {
    print('🚀 DashboardCubit: Starting loadProductAnalytics');
    // Only show loading state if we don't have any existing data
    if (state.productAnalytics == null) {
      print('🔄 No existing data, emitting loading state');
      emit(state.copyWith(state: DashboardStates.loading));
    }

    print('📡 Calling GetProductWeeklyAnalyticsUseCase...');
    final result = await _getProductWeeklyAnalyticsUseCase(const NoParams());
    result.fold(
      (failure) {
        print('❌ ProductAnalytics failed: ${failure.message}');
        emit(state.copyWith(
          state: DashboardStates.error,
          errorMessage: failure.message,
        ));
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

  /// Load product analytics for a specific category
  Future<void> loadProductAnalyticsForCategory(String category) async {
    print('🔄 DashboardCubit: Loading analytics for category: $category');

    // Don't emit loading state to avoid whole screen rebuild
    // Just update the data silently in the background

    print(
        '📡 Calling GetProductWeeklyAnalyticsForCategoryUseCase for category: $category');
    final result = await _getProductWeeklyAnalyticsForCategoryUseCase(category);

    result.fold(
      (failure) {
        print('❌ Category analytics failed: ${failure.message}');
        // Only emit error if we don't have existing data
        if (state.productAnalytics == null) {
          emit(state.copyWith(
            state: DashboardStates.error,
            errorMessage: failure.message,
          ));
        }
      },
      (productAnalytics) {
        print('✅ Category analytics loaded successfully for: $category');
        print('📊 Days count: ${productAnalytics.days.length}');

        // Update the current category in the analytics data
        final updatedAnalytics = productAnalytics.copyWith(
          currentCategory: category,
        );

        // Keep the current state (loaded) and just update the data
        emit(
          state.copyWith(
            state: DashboardStates.loaded, // Keep as loaded, don't change state
            productAnalytics: updatedAnalytics,
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
      // Load weekly stats first
      final weeklyStatsResult = await _getWeeklyStatsUseCase(const NoParams());

      weeklyStatsResult.fold(
        (failure) => emit(state.copyWith(
          state: DashboardStates.error,
          errorMessage: failure.message,
        )),
        (weeklyStats) async {
          // Load budget goals after weekly stats success
          final budgetGoalsResult = await _getBudgetGoalsUseCase(
            GetBudgetGoalsParams(
              page: page,
              limit: limit,
              duration: duration,
              startDate: startDate,
              endDate: endDate,
            ),
          );

          budgetGoalsResult.fold(
            (failure) => emit(state.copyWith(
              state: DashboardStates.error,
              errorMessage: failure.message,
            )),
            (budgetGoals) async {
              // Load product analytics after budget goals success
              final productAnalyticsResult =
                  await _getProductWeeklyAnalyticsUseCase(const NoParams());

              productAnalyticsResult.fold(
                (failure) => emit(state.copyWith(
                  state: DashboardStates.error,
                  errorMessage: failure.message,
                )),
                (productAnalytics) => emit(state.copyWith(
                  state: DashboardStates.loaded,
                  weeklyStats: weeklyStats,
                  budgetGoals: budgetGoals,
                  productAnalytics: productAnalytics,
                )),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        state: DashboardStates.error,
        errorMessage: 'An unexpected error occurred: $e',
      ));
    }
  }
}
