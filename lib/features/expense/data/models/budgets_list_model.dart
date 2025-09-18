import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budgets_list_entity.dart';
import 'package:xpensemate/features/expense/data/models/budgets_model.dart';

class ExpenseBudgetsListModel extends BudgetsListEntity {
  const ExpenseBudgetsListModel({
    required super.budgets,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory ExpenseBudgetsListModel.fromJson(Map<String, dynamic> json) {
    try {
      final budgets = (json['budgetGoals'] as List<dynamic>?)
              ?.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ExpenseBudgetsListModel(
        budgets: budgets,
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        totalPages: json['totalPages'] as int? ?? 1,
      );
    } on Exception catch (e) {
      AppLogger.e('Failed to parse ExpenseBudgetsListModel from json: $e');
      rethrow;
    }
  }

  factory ExpenseBudgetsListModel.fromEntity(BudgetsListEntity entity) =>
      ExpenseBudgetsListModel(
        budgets: entity.budgets.map(BudgetModel.fromEntity).toList(),
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  BudgetsListEntity toEntity() => BudgetsListEntity(
        budgets: budgets
            .map((budget) => (budget as BudgetModel).toEntity())
            .toList(),
        total: total,
        page: page,
        totalPages: totalPages,
      );

  Map<String, dynamic> toJson() => {
        'budgets':
            budgets.map((budget) => (budget as BudgetModel).toJson()).toList(),
        'total': total,
        'page': page,
        'totalPages': totalPages,
      };
}
