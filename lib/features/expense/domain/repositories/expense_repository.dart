import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
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

class ExpensePaginationEntity {
  ExpensePaginationEntity({
    required this.expenses,
    required this.total,
    required this.page,
    required this.totalPages,
  });
  final List<ExpenseEntity> expenses;
  final int total;
  final int page;
  final int totalPages;

  ExpensePaginationEntity copyWith({
    List<ExpenseEntity>? expenses,
    int? total,
    int? page,
    int? totalPages,
  }) =>
      ExpensePaginationEntity(
        expenses: expenses ?? this.expenses,
        total: total ?? this.total,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}
