import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class DeleteBudgetGoalUseCase extends UseCase<bool, DeleteBudgetGoalParams> {
  DeleteBudgetGoalUseCase(this.repository);
  
  final BudgetRepository repository;

  @override
  Future<Either<Failure, bool>> call(DeleteBudgetGoalParams params) =>
      repository.deleteBudgetGoal(params.id);
}

class DeleteBudgetGoalParams {
  const DeleteBudgetGoalParams({
    required this.id,
  });
  
  final String id;
}