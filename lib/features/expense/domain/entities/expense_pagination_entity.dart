import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';

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
