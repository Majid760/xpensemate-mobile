import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_specific_expense_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetSpecificExpensesUseCase
    extends UseCase<BudgetSpecificExpensesListEntity, GetBudgetSpecificExpensesUseCaseParams> {
  GetBudgetSpecificExpensesUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetSpecificExpensesListEntity>> call(
    GetBudgetSpecificExpensesUseCaseParams params,
  ) =>
      repository.getExpensesForSpecificBudgetGoal(params.budgetId);
}

class GetBudgetSpecificExpensesUseCaseParams {
  const GetBudgetSpecificExpensesUseCaseParams({
    required this.budgetId,
  });

  final String budgetId;
}