import 'package:xpensemate/features/expense/data/models/expense_model.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class ExpensePaginationModel extends ExpensePaginationEntity {
  ExpensePaginationModel({
    required super.expenses,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory ExpensePaginationModel.fromEntity(ExpensePaginationEntity entity) => ExpensePaginationModel(
        expenses: entity.expenses,
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  factory ExpensePaginationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final expensesList =
        (data['expenses'] as List<dynamic>?)?.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList() ??
            [];

    return ExpensePaginationModel(
      expenses: expensesList.map((e) => e.toEntity()).toList(),
      total: (data['total'] as int?) ?? 0,
      page: (data['page'] as int?) ?? 1,
      totalPages: (data['totalPages'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'expenses': expenses.map((e) => (e as ExpenseModel).toJson()).toList(),
          'total': total,
          'page': page,
          'totalPages': totalPages,
        }
      };

  ExpensePaginationEntity toEntity() => ExpensePaginationEntity(
        expenses: expenses,
        total: total,
        page: page,
        totalPages: totalPages,
      );
}
