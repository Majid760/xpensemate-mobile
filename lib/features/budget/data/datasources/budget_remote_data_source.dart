import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget/data/models/budget_goal_model.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_specific_expense_entity.dart';

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
  Future<Either<Failure, BudgetGoalsListModel>> getBudgetGoalByStatus(
    String budgetGoalId,
  );

  Future<Either<Failure, BudgetGoalsListModel>> getMonthlyBudgetGoalsSummary(
    String budgetGoalId,
  );

  Future<Either<Failure, BudgetSpecificExpensesListEntity>> getExpensesForSpecificBudgetGoal(
    String budgetGoalId,
  );

  Future<Either<Failure, BudgetGoalsInsightEntity>> getBudgetGoalsByPeriod(
    String period, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
