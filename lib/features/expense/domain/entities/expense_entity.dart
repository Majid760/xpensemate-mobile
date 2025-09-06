import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String? budgetGoalId;
  final DateTime date;
  final String time;
  final String location;
  final String categoryId;
  final String categoryName;
  final String detail;
  final String paymentMethod;
  final List<String> attachments;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RecurringEntity recurring;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    this.budgetGoalId,
    required this.date,
    required this.time,
    required this.location,
    required this.categoryId,
    required this.categoryName,
    required this.detail,
    required this.paymentMethod,
    required this.attachments,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.recurring,
  });

  ExpenseEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? budgetGoalId,
    DateTime? date,
    String? time,
    String? location,
    String? categoryId,
    String? categoryName,
    String? detail,
    String? paymentMethod,
    List<String>? attachments,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecurringEntity? recurring,
  }) =>
      ExpenseEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        budgetGoalId: budgetGoalId ?? this.budgetGoalId,
        date: date ?? this.date,
        time: time ?? this.time,
        location: location ?? this.location,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
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
        categoryName,
        detail,
        paymentMethod,
        attachments,
        isDeleted,
        createdAt,
        updatedAt,
        recurring,
      ];
}

class RecurringEntity extends Equatable {
  final bool isRecurring;
  final String frequency;

  const RecurringEntity({
    required this.isRecurring,
    required this.frequency,
  });

  RecurringEntity copyWith({
    bool? isRecurring,
    String? frequency,
  }) =>
      RecurringEntity(
        isRecurring: isRecurring ?? this.isRecurring,
        frequency: frequency ?? this.frequency,
      );

  @override
  List<Object?> get props => [isRecurring, frequency];
}
