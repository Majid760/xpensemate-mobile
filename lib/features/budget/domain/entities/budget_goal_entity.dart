import 'package:equatable/equatable.dart';

class BudgetGoalEntity extends Equatable {
  const BudgetGoalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.detail,
    required this.status,
    required this.priority,
    required this.progress,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.remainingBalance,
    required this.currentSpending,
  });

  final String id;
  final String userId;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String detail;
  final String status;
  final String priority;
  final int progress;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double remainingBalance;
  final double currentSpending;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        amount,
        date,
        category,
        detail,
        status,
        priority,
        progress,
        isDeleted,
        createdAt,
        updatedAt,
        remainingBalance,
        currentSpending,
      ];
}

class BudgetGoalsListEntity extends Equatable {
  const BudgetGoalsListEntity({
    required this.budgetGoals,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<BudgetGoalEntity> budgetGoals;
  final int total;
  final int page;
  final int totalPages;

  @override
  List<Object?> get props => [
        budgetGoals,
        total,
        page,
        totalPages,
      ];
}
