import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:xpensemate/features/expense/data/models/expense_pagination_model.dart';
import 'package:xpensemate/features/expense/data/models/expense_stats_model.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExpensePaginationEntity>> getExpenses({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? sortBy,
    bool? ascending,
  }) async {
    return await remoteDataSource.getExpenses(
      page: page,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      sortBy: sortBy,
      ascending: ascending,
    ).then((value) => value.fold(
          (failure) => Left(failure),
          (model) => Right(model.toEntity()),
        ));
  }

  @override
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDataSource.getExpenseStats(
      startDate: startDate,
      endDate: endDate,
    ).then((value) => value.fold(
          (failure) => Left(failure),
          (model) => Right(model.toEntity()),
        ));
  }
}