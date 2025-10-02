import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class CreateBudgetGoalUseCase
    extends UseCase<BudgetGoalEntity, CreateBudgetGoalParams> {
  CreateBudgetGoalUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalEntity>> call(
          CreateBudgetGoalParams params,) =>
      repository.createBudgetGoal(params.budgetGoal);
}

class CreateBudgetGoalParams {
  const CreateBudgetGoalParams({
    required this.budgetGoal,
  });

  final BudgetGoalEntity budgetGoal;
}
