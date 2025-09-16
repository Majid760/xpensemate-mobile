import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_pagination_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this.remoteDataSource);
  final ExpenseRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, ExpensePaginationEntity>> getExpenses({
    required int page,
    required int limit,
  }) async =>
      remoteDataSource
          .getExpenses(
            page: page,
            limit: limit,
          )
          .then(
            (value) => value.fold(
              Left.new,
              (model) => Right(model.toEntity()),
            ),
          );

  @override
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats({
    String? period,
  }) async =>
      remoteDataSource
          .getExpenseStats(
            period: period,
          )
          .then(
            (value) => value.fold(
              Left.new,
              (model) => Right(model.toEntity()),
            ),
          );

  @override
  Future<Either<Failure, bool>> deleteExpense(String expenseId) async =>
      remoteDataSource.deleteExpense(expenseId).then(
            (value) => value.fold(
              Left.new,
              Right.new,
            ),
          );

  @override
  Future<Either<Failure, ExpenseEntity>> updateExpense(
    ExpenseEntity expense,
  ) async =>
      remoteDataSource.updateExpense(expense).then(
            (value) => value.fold(
              Left.new,
              (model) => Right(model.toEntity()),
            ),
          );
}
