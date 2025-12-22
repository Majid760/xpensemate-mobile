import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/dashboard/data/models/budget_goals_model.dart';
import 'package:xpensemate/features/dashboard/data/models/product_weekly_analytics_model.dart';
import 'package:xpensemate/features/dashboard/data/models/weekly_stats_model.dart';

abstract class DashboardRemoteDataSource {
  /// Fetches weekly statistics
  Future<Either<Failure, WeeklyStatsModel>> getWeeklyStats();

  /// Fetches budget goals
  Future<Either<Failure, BudgetGoalsModel>> getBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetches product weekly analytics
  Future<Either<Failure, ProductWeeklyAnalyticsModel>>
      getProductWeeklyAnalytics();

  /// Fetches product weekly analytics for a specific category
  Future<Either<Failure, ProductWeeklyAnalyticsModel>>
      getProductWeeklyAnalyticsForCategory();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._networkClient);
  final NetworkClient _networkClient;

  @override
  Future<Either<Failure, WeeklyStatsModel>> getWeeklyStats({
    String? filterQuery,
  }) {
    final queryParams = <String, dynamic>{};
    queryParams['filter_query'] = filterQuery ?? "weekly";
    return _networkClient.get(
      NetworkConfigs.weeklyStats,
      query: queryParams,
      fromJson: WeeklyStatsModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, BudgetGoalsModel>> getBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final queryParams = <String, dynamic>{};

    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (duration != null) queryParams['duration'] = duration;
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    return _networkClient.get(
      NetworkConfigs.budgetGoals,
      query: queryParams,
      fromJson: BudgetGoalsModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, ProductWeeklyAnalyticsModel>>
      getProductWeeklyAnalytics() => _networkClient.get(
            NetworkConfigs.expenseStats,
            fromJson: ProductWeeklyAnalyticsModel.fromJson,
          );

  @override
  Future<Either<Failure, ProductWeeklyAnalyticsModel>>
      getProductWeeklyAnalyticsForCategory() => _networkClient.get(
            NetworkConfigs.expenseStats,
            fromJson: ProductWeeklyAnalyticsModel.fromJson,
          );
}
