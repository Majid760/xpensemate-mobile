import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/expense/data/models/expense_model.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class ExpensePaginationModel extends ExpensePaginationEntity {
  ExpensePaginationModel({
    required super.expenses,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory ExpensePaginationModel.fromEntity(ExpensePaginationEntity entity) =>
      ExpensePaginationModel(
        expenses: entity.expenses,
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  factory ExpensePaginationModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json as Map<String, dynamic>? ?? {};

      final expensesList = (data['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return ExpensePaginationModel(
        expenses: expensesList.map((e) => e.toEntity()).toList(),
        total: _parseToInt(data['total']) ?? 0,
        page: _parseToInt(data['page']) ?? 1,
        totalPages: _parseToInt(data['totalPages']) ?? 1,
      );
    } on Exception catch (e) {
      AppLogger.e("error while parsing expense pagination model => $e");
      throw Exception(e);
    }
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'expenses':
              expenses.map((e) => (e as ExpenseModel).toJson()).toList(),
          'total': total,
          'page': page,
          'totalPages': totalPages,
        },
      };

  ExpensePaginationEntity toEntity() => ExpensePaginationEntity(
        expenses: expenses,
        total: total,
        page: page,
        totalPages: totalPages,
      );

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value);
    }

    // Handle double values that might come from API
    if (value is double) {
      return value.toInt();
    }

    return null;
  }
}
