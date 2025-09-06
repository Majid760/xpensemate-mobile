import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

abstract class ExpenseRepository {
  /// Fetch expenses with pagination
  Future<Either<Failure, ExpensePaginationEntity>> getExpenses({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? sortBy,
    bool? ascending,
  });

  /// Fetch expense statistics
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ExpensePaginationEntity {
  final List<ExpenseEntity> expenses;
  final int total;
  final int page;
  final int totalPages;

  ExpensePaginationEntity({
    required this.expenses,
    required this.total,
    required this.page,
    required this.totalPages,
  });

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