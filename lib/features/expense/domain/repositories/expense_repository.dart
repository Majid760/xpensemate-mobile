import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_pagination_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, ExpensePaginationEntity>> getExpenses({
    required int page,
    required int limit,
  });
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats({
    String? period,
  });

  Future<Either<Failure, bool>> deleteExpense(String expenseId);

  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense);
}
