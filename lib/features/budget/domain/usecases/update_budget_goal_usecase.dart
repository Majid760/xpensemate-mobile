import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class UpdateBudgetGoalUseCase
    extends UseCase<BudgetGoalEntity, UpdateBudgetGoalParams> {
  UpdateBudgetGoalUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalEntity>> call(
    UpdateBudgetGoalParams params,
  ) =>
      repository.updateBudgetGoal(params.budgetGoal);
}

class UpdateBudgetGoalParams {
  const UpdateBudgetGoalParams({
    required this.budgetGoal,
  });

  final BudgetGoalEntity budgetGoal;
}
