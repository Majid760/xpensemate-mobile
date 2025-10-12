import 'package:equatable/equatable.dart';

class BudgetSpecificExpensesEntity extends Equatable {
  const BudgetSpecificExpensesEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.budgetGoalId,
    required this.date,
    required this.time,
    required this.location,
    required this.categoryId,
    required this.category,
    required this.detail,
    required this.paymentMethod,
    required this.attachments,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.recurring,
  });

  final String id;
  final String userId;
  final String name;
  final double amount;
  final String budgetGoalId;
  final DateTime date;
  final String time;
  final String location;
  final String categoryId;
  final String category;
  final String detail;
  final String paymentMethod;
  final List<String> attachments;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RecurringBudgetExpensesEntity recurring;

  //copywith
  BudgetSpecificExpensesEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? budgetGoalId,
    DateTime? date,
    String? time,
    String? location,
    String? categoryId,
    String? category,
    String? detail,
    String? paymentMethod,
    List<String>? attachments,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecurringBudgetExpensesEntity? recurring,
  }) =>
      BudgetSpecificExpensesEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        budgetGoalId: budgetGoalId ?? this.budgetGoalId,
        date: date ?? this.date,
        time: time ?? this.time,
        location: location ?? this.location,
        categoryId: categoryId ?? this.categoryId,
        category: category ?? this.category,
        detail: detail ?? this.detail,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        attachments: attachments ?? this.attachments,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        recurring: recurring ?? this.recurring,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        amount,
        budgetGoalId,
        date,
        time,
        location,
        categoryId,
        category,
        detail,
        paymentMethod,
        attachments,
        isDeleted,
        createdAt,
        updatedAt,
        recurring,
      ];
}

class RecurringBudgetExpensesEntity extends Equatable {
  const RecurringBudgetExpensesEntity({
    required this.isRecurring,
    required this.frequency,
  });

  // from json
  factory RecurringBudgetExpensesEntity.fromJson(Map<String, dynamic> json) =>
      RecurringBudgetExpensesEntity(
        isRecurring: json['is_recurring'] as bool,
        frequency: json['frequency'] as String,
      );

  // to json
  Map<String, dynamic> toJson() => {
        'is_recurring': isRecurring,
        'frequency': frequency,
      };

  // to entity

  // copywith
  RecurringBudgetExpensesEntity copyWith({
    bool? isRecurring,
    String? frequency,
  }) =>
      RecurringBudgetExpensesEntity(
        isRecurring: isRecurring ?? this.isRecurring,
        frequency: frequency ?? this.frequency,
      );

  final bool isRecurring;
  final String frequency;

  @override
  List<Object?> get props => [isRecurring, frequency];
}

class BudgetSpecificExpensesListEntity extends Equatable {
  const BudgetSpecificExpensesListEntity({
    required this.expenses,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<BudgetSpecificExpensesEntity> expenses;
  final int total;
  final int page;
  final int totalPages;

  //copywith
  BudgetSpecificExpensesListEntity copyWith({
    List<BudgetSpecificExpensesEntity>? expenses,
    int? total,
    int? page,
    int? totalPages,
  }) =>
      BudgetSpecificExpensesListEntity(
        expenses: expenses ?? this.expenses,
        total: total ?? this.total,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
  @override
  List<Object?> get props => [
        expenses,
        total,
        page,
        totalPages,
      ];
}
