import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetGoalsByStatusUseCase extends UseCase<BudgetGoalsListEntity, GetBudgetGoalsByStatusParams> {
  GetBudgetGoalsByStatusUseCase(this.repository);
  
  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalsListEntity>> call(GetBudgetGoalsByStatusParams params) =>
      repository.getBudgetGoals(
        status: params.status,
        page: params.page,
        limit: params.limit,
        category: params.category,
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class GetBudgetGoalsByStatusParams {
  const GetBudgetGoalsByStatusParams({
    required this.status,
    this.page,
    this.limit,
    this.category,
    this.startDate,
    this.endDate,
  });
  
  final String status;
  final int? page;
  final int? limit;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
}