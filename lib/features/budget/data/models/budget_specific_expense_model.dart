import 'package:flutter/widgets.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_specific_expense_entity.dart';

class RecurringBudgetExpensesModel extends RecurringBudgetExpensesEntity {
  const RecurringBudgetExpensesModel({
    required super.isRecurring,
    required super.frequency,
  });

  factory RecurringBudgetExpensesModel.fromEntity(
    RecurringBudgetExpensesEntity entity,
  ) =>
      RecurringBudgetExpensesModel(
        isRecurring: entity.isRecurring,
        frequency: entity.frequency,
      );

  factory RecurringBudgetExpensesModel.fromJson(Map<String, dynamic> json) =>
      RecurringBudgetExpensesModel(
        isRecurring: json['is_recurring'] as bool? ?? false,
        frequency: json['frequency'] as String? ?? 'monthly',
      );

  @override
  Map<String, dynamic> toJson() => {
        'is_recurring': isRecurring,
        'frequency': frequency,
      };

  RecurringBudgetExpensesEntity toEntity() => RecurringBudgetExpensesEntity(
        isRecurring: isRecurring,
        frequency: frequency,
      );
}

class BudgetSpecificExpensesModel extends BudgetSpecificExpensesEntity {
  const BudgetSpecificExpensesModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.budgetGoalId,
    required super.date,
    required super.time,
    required super.location,
    required super.categoryId,
    required super.category,
    required super.detail,
    required super.paymentMethod,
    required super.attachments,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
    required super.recurring,
  });

  factory BudgetSpecificExpensesModel.fromEntity(
    BudgetSpecificExpensesEntity entity,
  ) =>
      BudgetSpecificExpensesModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        amount: entity.amount,
        budgetGoalId: entity.budgetGoalId,
        date: entity.date,
        time: entity.time,
        location: entity.location,
        categoryId: entity.categoryId,
        category: entity.category,
        detail: entity.detail,
        paymentMethod: entity.paymentMethod,
        attachments: entity.attachments,
        isDeleted: entity.isDeleted,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        recurring: RecurringBudgetExpensesModel.fromEntity(entity.recurring),
      );

  factory BudgetSpecificExpensesModel.fromJson(Map<String, dynamic> json) {
    try {
      final recurringData = json['recurring'] as Map<String, dynamic>? ?? {};

      return BudgetSpecificExpensesModel(
        id: json['_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        budgetGoalId: json['budget_goal_id'] as String? ?? '',
        date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String(),
        ),
        time: json['time'] as String? ?? '',
        location: json['location'] as String? ?? '',
        categoryId: json['category_id'] as String? ?? '',
        category: json['category'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        paymentMethod: json['payment_method'] as String? ?? '',
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        isDeleted: json['is_deleted'] as bool? ?? false,
        createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        recurring: RecurringBudgetExpensesModel.fromJson(recurringData),
      );
    } on Exception catch (e) {
      debugPrint('Error parsing BudgetSpecificExpenseModel=> $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user_id': userId,
        'name': name,
        'amount': amount,
        'budget_goal_id': budgetGoalId,
        'date': date.toIso8601String(),
        'time': time,
        'location': location,
        'category_id': categoryId,
        'category': category,
        'detail': detail,
        'payment_method': paymentMethod,
        'attachments': attachments,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'recurring':
            RecurringBudgetExpensesModel.fromEntity(recurring).toJson(),
      };

  BudgetSpecificExpensesEntity toEntity() => BudgetSpecificExpensesEntity(
        id: id,
        userId: userId,
        name: name,
        amount: amount,
        budgetGoalId: budgetGoalId,
        date: date,
        time: time,
        location: location,
        categoryId: categoryId,
        category: category,
        detail: detail,
        paymentMethod: paymentMethod,
        attachments: attachments,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        recurring: recurring,
      );
}

class BudgetSpecificExpensesListModel extends BudgetSpecificExpensesListEntity {
  const BudgetSpecificExpensesListModel({
    required super.expenses,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory BudgetSpecificExpensesListModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct data format and wrapped data format
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return BudgetSpecificExpensesListModel(
      expenses: (data['expenses'] as List? ?? [])
          .map(
            (e) =>
                BudgetSpecificExpensesModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      total:
          (data['total'] as int?) ?? (data['expenses'] as List? ?? []).length,
      page: (data['page'] as int?) ?? 1,
      totalPages: (data['totalPages'] as int?) ?? 1,
    );
  }

  factory BudgetSpecificExpensesListModel.fromEntity(
    BudgetSpecificExpensesListEntity entity,
  ) =>
      BudgetSpecificExpensesListModel(
        expenses: entity.expenses
            .map(BudgetSpecificExpensesModel.fromEntity)
            .toList(),
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  BudgetSpecificExpensesListModel toEntity() => BudgetSpecificExpensesListModel(
        expenses: expenses
            .map((model) => (model as BudgetSpecificExpensesModel).toEntity())
            .toList(),
        total: total,
        page: page,
        totalPages: totalPages,
      );

  Map<String, dynamic> toJson() => {
        'data': {
          'expenses': expenses
              .map((e) => (e as BudgetSpecificExpensesModel).toJson())
              .toList(),
          'total': total,
          'page': page,
          'totalPages': totalPages,
        },
      };
}
