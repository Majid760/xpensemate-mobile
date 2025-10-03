import 'package:equatable/equatable.dart';

class BudgetExpenseEntity extends Equatable {
  const BudgetExpenseEntity({
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
  final RecurringExpenseEntity recurring;

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

class RecurringExpenseEntity extends Equatable {
  const RecurringExpenseEntity({
    required this.isRecurring,
    required this.frequency,
  });

  final bool isRecurring;
  final String frequency;

  @override
  List<Object?> get props => [isRecurring, frequency];
}

class BudgetExpensesListEntity extends Equatable {
  const BudgetExpensesListEntity({
    required this.expenses,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<BudgetExpenseEntity> expenses;
  final int total;
  final int page;
  final int totalPages;

  @override
  List<Object?> get props => [
        expenses,
        total,
        page,
        totalPages,
      ];
}
