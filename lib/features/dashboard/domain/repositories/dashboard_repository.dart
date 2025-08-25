import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';

import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
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
}