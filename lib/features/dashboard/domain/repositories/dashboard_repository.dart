import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';

abstract class DashboardRepository {
  /// Fetches weekly statistics for the dashboard
  Future<Either<Failure, WeeklyStatsEntity>> getWeeklyStats();

  /// Fetches budget goals with optional pagination and filters
  Future<Either<Failure, BudgetGoalsEntity>> getBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetches product weekly analytics for the dashboard
  Future<Either<Failure, ProductWeeklyAnalyticsEntity>>
      getProductWeeklyAnalytics();

  /// Fetches product weekly analytics for a specific category
  Future<Either<Failure, ProductWeeklyAnalyticsEntity>>
      getProductWeeklyAnalyticsForCategory(String category);
}
