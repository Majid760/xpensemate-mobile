import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:xpensemate/features/budget/data/models/budget_expense_model.dart';
import 'package:xpensemate/features/budget/data/models/budget_goal_model.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  BudgetRemoteDataSourceImpl(this._networkClient);

  final NetworkClient _networkClient;

  @override
  Future<Either<Failure, BudgetGoalsListModel>> getBudgetGoals({
    int? page,
    int? limit,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};

    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    return _networkClient.get(
      NetworkConfigs.budgetGoals,
      query: queryParams,
      fromJson: BudgetGoalsListModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, BudgetGoalModel>> createBudgetGoal(
    BudgetGoalEntity budgetGoal,
  ) async =>
      _networkClient.post(
        NetworkConfigs.budgetGoals,
        data: budgetGoal is BudgetGoalModel
            ? budgetGoal.toJson()
            : BudgetGoalModel.fromEntity(budgetGoal).toJson(),
        fromJson: BudgetGoalModel.fromJson,
      );

  @override
  Future<Either<Failure, BudgetGoalModel>> updateBudgetGoal(
    BudgetGoalEntity budgetGoal,
  ) =>
      _networkClient.put(
        '${NetworkConfigs.budgetGoals}/${budgetGoal.id}',
        data: budgetGoal is BudgetGoalModel
            ? budgetGoal.toJson()
            : BudgetGoalModel.fromEntity(budgetGoal).toJson(),
        fromJson: BudgetGoalModel.fromJson,
      );

  @override
  Future<Either<Failure, bool>> deleteBudgetGoal(String budgetGoalId) async =>
      _networkClient.delete(
        '${NetworkConfigs.budgetGoals}/$budgetGoalId',
        fromJson: (json) => json['data'] as bool? ?? true,
      );

  @override
  Future<Either<Failure, BudgetExpensesListModel>>
      getExpensesForSpecificBudgetGoal(String budgetGoalId) =>
          _networkClient.get(
            '${NetworkConfigs.getAllExpensesOfBudgetGoal}/$budgetGoalId/expenses',
            fromJson: BudgetExpensesListModel.fromJson,
          );

  @override
  Future<Either<Failure, BudgetGoalsListModel>> getBudgetGoalByStatus(
    String budgetGoalId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, BudgetGoalsListModel>> getMonthlyBudgetGoalsSummary(
    String budgetGoalId,
  ) {
    throw UnimplementedError();
  }
}
