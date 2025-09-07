import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/expense/data/models/expense_pagination_model.dart';
import 'package:xpensemate/features/expense/data/models/expense_stats_model.dart';

abstract class ExpenseRemoteDataSource {
  /// Fetches expenses with pagination (matches web app: /expenses?page=${page}&limit=${limit})
  Future<Either<Failure, ExpensePaginationModel>> getExpenses({
    required int page,
    required int limit,
  });

  /// Fetches expense statistics
  Future<Either<Failure, ExpenseStatsModel>> getExpenseStats({
    String? period,
  });
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceImpl(this._networkClient);
  final NetworkClient _networkClient;

  @override
  Future<Either<Failure, ExpensePaginationModel>> getExpenses({
    required int page,
    required int limit,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    return _networkClient.get(
      NetworkConfigs.getAllExpenses,
      query: queryParams,
      fromJson: ExpensePaginationModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, ExpenseStatsModel>> getExpenseStats({
    String? period,
  }) {
    final queryParams = <String, dynamic>{};
    queryParams['period'] = period ?? 'weekly';
    return _networkClient.get(
      NetworkConfigs.expenseInsight,
      query: queryParams,
      fromJson: ExpenseStatsModel.fromJson,
    );
  }
}
