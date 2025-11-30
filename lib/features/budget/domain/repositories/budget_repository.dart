import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_specific_expense_entity.dart';

abstract class BudgetRepository {
  /// Fetches budget goals with optional pagination and filters
  Future<Either<Failure, BudgetGoalsListEntity>> getBudgetGoals({
    int? page,
    int? limit,
    String? category,
    String? filterQuery,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetches a specific budget goal by ID
  Future<Either<Failure, BudgetGoalEntity>> getBudgetGoal(String id);

  /// Creates a new budget goal
  Future<Either<Failure, BudgetGoalEntity>> createBudgetGoal(
    BudgetGoalEntity budgetGoal,
  );

  /// Updates an existing budget goal
  Future<Either<Failure, BudgetGoalEntity>> updateBudgetGoal(
    BudgetGoalEntity budgetGoal,
  );

  /// Deletes a budget goal
  Future<Either<Failure, bool>> deleteBudgetGoal(String id);

  Future<Either<Failure, BudgetSpecificExpensesListEntity>>
      getExpensesForSpecificBudgetGoal(String budgetGoalId);

  Future<Either<Failure, BudgetGoalsInsightEntity>> getBudgetGoalsByPeriod({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  });
}
