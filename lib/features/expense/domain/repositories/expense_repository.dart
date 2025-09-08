import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_pagination_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

abstract class ExpenseRepository {
  /// Fetch expenses with pagination (matches web app: /expenses?page=${page}&limit=${limit})
  Future<Either<Failure, ExpensePaginationEntity>> getExpenses({
    required int page,
    required int limit,
  });

  /// Fetch expense statistics
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats({
    String? period,
  });
}
