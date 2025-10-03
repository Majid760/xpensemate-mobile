import 'package:xpensemate/features/budget/domain/entities/budget_expense_entity.dart';

class BudgetExpenseModel extends BudgetExpenseEntity {
  const BudgetExpenseModel({
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

  factory BudgetExpenseModel.fromEntity(BudgetExpenseEntity entity) =>
      BudgetExpenseModel(
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
        recurring: RecurringExpenseModel.fromEntity(entity.recurring),
      );

  factory BudgetExpenseModel.fromJson(Map<String, dynamic> json) {
    final recurringData = json['recurring'] as Map<String, dynamic>? ?? {};

    return BudgetExpenseModel(
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
      recurring: RecurringExpenseModel.fromJson(recurringData),
    );
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
        'payment_method': paymentMethod.toLowerCase().replaceAll(' ', '_'),
        'attachments': attachments,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'recurring': RecurringExpenseModel.fromEntity(recurring).toJson(),
      };

  BudgetExpenseEntity toEntity() => BudgetExpenseEntity(
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

class RecurringExpenseModel extends RecurringExpenseEntity {
  const RecurringExpenseModel({
    required super.isRecurring,
    required super.frequency,
  });

  factory RecurringExpenseModel.fromEntity(RecurringExpenseEntity entity) =>
      RecurringExpenseModel(
        isRecurring: entity.isRecurring,
        frequency: entity.frequency,
      );

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) =>
      RecurringExpenseModel(
        isRecurring: json['is_recurring'] as bool? ?? false,
        frequency: json['frequency'] as String? ?? 'monthly',
      );

  Map<String, dynamic> toJson() => {
        'is_recurring': isRecurring,
        'frequency': frequency,
      };

  RecurringExpenseEntity toEntity() => RecurringExpenseEntity(
        isRecurring: isRecurring,
        frequency: frequency,
      );
}

class BudgetExpensesListModel extends BudgetExpensesListEntity {
  const BudgetExpensesListModel({
    required super.expenses,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory BudgetExpensesListModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return BudgetExpensesListModel(
      expenses: (data['expenses'] as List? ?? [])
          .map((e) => BudgetExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  factory BudgetExpensesListModel.fromEntity(BudgetExpensesListEntity entity) =>
      BudgetExpensesListModel(
        expenses: entity.expenses.map(BudgetExpenseModel.fromEntity).toList(),
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  BudgetExpensesListEntity toEntity() => BudgetExpensesListEntity(
        expenses: expenses
            .map((model) => (model as BudgetExpenseModel).toEntity())
            .toList(),
        total: total,
        page: page,
        totalPages: totalPages,
      );

  Map<String, dynamic> toJson() => {
        'data': {
          'expenses':
              expenses.map((e) => (e as BudgetExpenseModel).toJson()).toList(),
          'total': total,
          'page': page,
          'totalPages': totalPages,
        },
      };
}
