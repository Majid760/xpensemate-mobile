import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';

class BudgetGoalModel extends BudgetGoalEntity {
  const BudgetGoalModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.date,
    required super.category,
    required super.detail,
    required super.status,
    required super.priority,
    required super.progress,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
    required super.remainingBalance,
    required super.currentSpending,
  });

  factory BudgetGoalModel.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetGoalModel(
        id: json['_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        category: json['category'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        status: json['status'] as String? ?? '',
        priority: json['priority'] as String? ?? '',
        progress: json['progress'] as int? ?? 0,
        isDeleted: json['is_deleted'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0.0,
        currentSpending: (json['currentSpending'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      AppLogger.e("Error parsing BudgetGoalModel from JSON", e);
      rethrow;
    }
  }

  factory BudgetGoalModel.fromEntity(BudgetGoalEntity entity) =>
      BudgetGoalModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        amount: entity.amount,
        date: entity.date,
        category: entity.category,
        detail: entity.detail,
        status: entity.status,
        priority: entity.priority,
        progress: entity.progress,
        isDeleted: entity.isDeleted,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        remainingBalance: entity.remainingBalance,
        currentSpending: entity.currentSpending,
      );

  BudgetGoalEntity toEntity() => BudgetGoalEntity(
        id: id,
        userId: userId,
        name: name,
        amount: amount,
        date: date,
        category: category,
        detail: detail,
        status: status,
        priority: priority,
        progress: progress,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        remainingBalance: remainingBalance,
        currentSpending: currentSpending,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user_id': userId,
        'name': name,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'detail': detail,
        'status': status,
        'priority': priority,
        'progress': progress,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'remainingBalance': remainingBalance,
        'currentSpending': currentSpending,
      };
}

class BudgetGoalsListModel extends BudgetGoalsListEntity {
  const BudgetGoalsListModel({
    required super.budgetGoals,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory BudgetGoalsListModel.fromEntity(BudgetGoalsListEntity entity) =>
      BudgetGoalsListModel(
        budgetGoals:
            entity.budgetGoals.map(BudgetGoalModel.fromEntity).toList(),
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  factory BudgetGoalsListModel.fromJson(Map<String, dynamic> json) {
    try {
      print('this is json wowoowowowo=> ${json}');
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final BudgetGoalsListModel budgetGoalsListModel = BudgetGoalsListModel(
        budgetGoals: _parseBudgetGoalsList(data['budgetGoals'] as List? ?? []),
        total: data['total'] as int? ?? 0,
        page: data['page'] as int? ?? 1,
        totalPages: data['totalPages'] as int? ?? 1,
      );
      print('this is budgetGoalsListModel => $budgetGoalsListModel');
      return budgetGoalsListModel;
    } catch (e) {
      AppLogger.e("Error parsing BudgetGoalsListModel from JSON", e);
      rethrow;
    }
  }

  // Helper method to parse budget goals list - uses conditional approach for performance
  static List<BudgetGoalModel> _parseBudgetGoalsList(List<dynamic> jsonList) {
    if (jsonList.isEmpty) return [];

    final typedList = jsonList.cast<Map<String, dynamic>>();

    return typedList.map(BudgetGoalModel.fromJson).toList();
  }

  BudgetGoalsListEntity toEntity() => BudgetGoalsListEntity(
        budgetGoals: budgetGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
        total: total,
        page: page,
        totalPages: totalPages,
      );

  Map<String, dynamic> toJson() => {
        'data': {
          'budgetGoals':
              budgetGoals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
          'total': total,
          'page': page,
          'totalPages': totalPages,
        },
      };
}
