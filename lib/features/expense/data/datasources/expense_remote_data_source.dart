import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/expense/data/models/expense_pagination_model.dart';
import 'package:xpensemate/features/expense/data/models/expense_stats_model.dart';

abstract class ExpenseRemoteDataSource {
  /// Fetches expenses with pagination and filtering
  Future<Either<Failure, ExpensePaginationModel>> getExpenses({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? sortBy,
    bool? ascending,
  });

  /// Fetches expense statistics
  Future<Either<Failure, ExpenseStatsModel>> getExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceImpl(this._networkClient);
  final NetworkClient _networkClient;

  @override
  Future<Either<Failure, ExpensePaginationModel>> getExpenses({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? sortBy,
    bool? ascending,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId;
    }
    if (sortBy != null) {
      queryParams['sortBy'] = sortBy;
    }
    if (ascending != null) {
      queryParams['ascending'] = ascending;
    }
    
    return _networkClient.get(
      NetworkConfigs.getAllExpenses,
      query: queryParams,
      fromJson: ExpensePaginationModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, ExpenseStatsModel>> getExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final queryParams = <String, dynamic>{};
    
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    
    return _networkClient.get(
      NetworkConfigs.expenseInsight,
      query: queryParams,
      fromJson: ExpenseStatsModel.fromJson,
    );
  }
}