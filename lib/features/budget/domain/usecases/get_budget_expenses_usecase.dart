import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetExpensesUseCase
    extends UseCase<BudgetGoalEntity, GetBudgetExpensesUseCaseParams> {
  GetBudgetExpensesUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalEntity>> call(
    GetBudgetExpensesUseCaseParams params,
  ) =>
      repository.getBudgetGoal(params.budgetId);
}

class GetBudgetExpensesUseCaseParams {
  const GetBudgetExpensesUseCaseParams({
    required this.budgetId,
  });

  final String budgetId;
}
