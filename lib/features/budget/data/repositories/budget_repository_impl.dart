import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required this.remoteDataSource,
  });

  final BudgetRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, BudgetGoalsListEntity>> getBudgetGoals({
    int? page,
    int? limit,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      remoteDataSource.getBudgetGoals(
        page: page,
        limit: limit,
        category: category,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Future<Either<Failure, BudgetGoalEntity>> createBudgetGoal(
    BudgetGoalEntity budgetGoal,
  ) =>
      remoteDataSource.createBudgetGoal(budgetGoal);

  @override
  Future<Either<Failure, BudgetGoalEntity>> updateBudgetGoal(
    BudgetGoalEntity budgetGoal,
  ) =>
      remoteDataSource.updateBudgetGoal(budgetGoal);

  @override
  Future<Either<Failure, bool>> deleteBudgetGoal(
    String budgetGoalId,
  ) =>
      remoteDataSource.deleteBudgetGoal(budgetGoalId);

  @override
  Future<Either<Failure, BudgetGoalEntity>> getBudgetGoal(String id) {
    throw UnimplementedError();
  }
}
