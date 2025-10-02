import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetGoalsByCategoryUseCase extends UseCase<BudgetGoalsListEntity, GetBudgetGoalsByCategoryParams> {
  GetBudgetGoalsByCategoryUseCase(this.repository);
  
  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalsListEntity>> call(GetBudgetGoalsByCategoryParams params) =>
      repository.getBudgetGoals(
        category: params.category,
        page: params.page,
        limit: params.limit,
        status: params.status,
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class GetBudgetGoalsByCategoryParams {
  const GetBudgetGoalsByCategoryParams({
    required this.category,
    this.page,
    this.limit,
    this.status,
    this.startDate,
    this.endDate,
  });
  
  final String category;
  final int? page;
  final int? limit;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
}