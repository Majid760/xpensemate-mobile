import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetBudgetGoalsUseCase extends UseCase<BudgetGoalsEntity, GetBudgetGoalsParams> {
  GetBudgetGoalsUseCase(this.repository);
  
  final DashboardRepository repository;

  @override
  Future<Either<Failure, BudgetGoalsEntity>> call(GetBudgetGoalsParams params) =>
      repository.getBudgetGoals(
        page: params.page,
        limit: params.limit,
        duration: params.duration,
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class GetBudgetGoalsParams {
  const GetBudgetGoalsParams({
    this.page,
    this.limit,
    this.duration,
    this.startDate,
    this.endDate,
  });
  
  final int? page;
  final int? limit;
  final String? duration;
  final DateTime? startDate;
  final DateTime? endDate;
}