import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, WeeklyStatsEntity>> getWeeklyStats() async {
    final remoteWeeklyStats = await _remoteDataSource.getWeeklyStats();
    return remoteWeeklyStats.fold(
      Left.new,
      (remoteWeeklyStats) {
        final weeklyStats = remoteWeeklyStats;
        return right(weeklyStats.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, BudgetGoalsEntity>> getBudgetGoals({
    int? page,
    int? limit,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final remoteBudgetGoals = await _remoteDataSource.getBudgetGoals(
      page: page,
      limit: limit,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
    );
    return remoteBudgetGoals.fold(
      Left.new,
      (remoteBudgetGoals) => right(remoteBudgetGoals.toEntity()),
    );
  }
}