import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';
import 'package:xpensemate/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetWeeklyStatsUseCase extends UseCase<WeeklyStatsEntity, NoParams> {
  GetWeeklyStatsUseCase(this.repository);
  
  final DashboardRepository repository;

  @override
  Future<Either<Failure, WeeklyStatsEntity>> call(NoParams params) =>
      repository.getWeeklyStats();
}