import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetGoalByIdUseCase extends UseCase<BudgetGoalEntity, GetBudgetGoalByIdParams> {
  GetBudgetGoalByIdUseCase(this.repository);
  
  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalEntity>> call(GetBudgetGoalByIdParams params) =>
      repository.getBudgetGoal(params.id);
}

class GetBudgetGoalByIdParams {
  const GetBudgetGoalByIdParams({
    required this.id,
  });
  
  final String id;
}