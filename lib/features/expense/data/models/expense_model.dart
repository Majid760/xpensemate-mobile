import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    super.budgetGoalId,
    required super.date,
    required super.time,
    required super.location,
    required super.categoryId,
    required super.categoryName,
    required super.detail,
    required super.paymentMethod,
    required super.attachments,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
    required super.recurring,
  });

  factory ExpenseModel.fromEntity(ExpenseEntity entity) => ExpenseModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      amount: entity.amount,
      budgetGoalId: entity.budgetGoalId,
      date: entity.date,
      time: entity.time,
      location: entity.location,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      detail: entity.detail,
      paymentMethod: entity.paymentMethod,
      attachments: entity.attachments,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      recurring: RecurringModel.fromEntity(entity.recurring),
    );

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final recurringData = json['recurring'] as Map<String, dynamic>? ?? {};

    return ExpenseModel(
      id: json['_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      budgetGoalId: json['budget_goal_id'] as String?,
      date: DateTime.parse(
        json['date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      categoryId: json['category_id'] is Map<String, dynamic>
          ? (json['category_id']['_id'] as String? ?? '')
          : (json['category_id'] as String? ?? ''),
      categoryName: json['category_id'] is Map<String, dynamic>
          ? (json['category_id']['name'] as String? ?? '')
          : (json['category'] as String? ?? ''),
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
      recurring: RecurringModel.fromJson(recurringData),
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
        'category': categoryName,
        'detail': detail,
        // payment_method will like this credit_card', 'debit_card',
        'payment_method': paymentMethod.toLowerCase().replaceAll(' ', '_'),
        'attachments': attachments,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'recurring': RecurringModel.fromEntity(recurring).toJson(),
      };

  ExpenseEntity toEntity() => ExpenseEntity(
        id: id,
        userId: userId,
        name: name,
        amount: amount,
        budgetGoalId: budgetGoalId,
        date: date,
        time: time,
        location: location,
        categoryId: categoryId,
        categoryName: categoryName,
        detail: detail,
        paymentMethod: paymentMethod,
        attachments: attachments,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        recurring: recurring,
      );
}

class RecurringModel extends RecurringEntity {
  const RecurringModel({
    required super.isRecurring,
    required super.frequency,
  });

  factory RecurringModel.fromEntity(RecurringEntity entity) => RecurringModel(
        isRecurring: entity.isRecurring,
        frequency: entity.frequency,
      );

  factory RecurringModel.fromJson(Map<String, dynamic> json) => RecurringModel(
        isRecurring: json['is_recurring'] as bool? ?? false,
        frequency: json['frequency'] as String? ?? 'monthly',
      );

  Map<String, dynamic> toJson() => {
        'is_recurring': isRecurring,
        'frequency': frequency,
      };

  RecurringEntity toEntity() => RecurringEntity(
        isRecurring: isRecurring,
        frequency: frequency,
      );
}
