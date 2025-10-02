import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget/data/models/budget_goal_model.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';

abstract class BudgetRemoteDataSource {
  Future<Either<Failure, BudgetGoalsListModel>> getBudgetGoals({
    int? page,
    int? limit,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, BudgetGoalModel>> createBudgetGoal(
    BudgetGoalEntity budgetGoal,
  );

  Future<Either<Failure, BudgetGoalModel>> updateBudgetGoal(
    BudgetGoalEntity budgetGoal,
  );

  Future<Either<Failure, bool>> deleteBudgetGoal(String budgetGoalId);
}
