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

  // copywith

  BudgetGoalEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    DateTime? date,
    String? category,
    String? detail,
    String? status,
    String? priority,
    int? progress,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? remainingBalance,
    double? currentSpending,
  }) =>
      BudgetGoalEntity(
        currentSpending: currentSpending ?? this.currentSpending,
        priority: priority ?? this.priority,
        progress: progress ?? this.progress,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        remainingBalance: remainingBalance ?? this.remainingBalance,
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        category: category ?? this.category,
        detail: detail ?? this.detail,
        status: status ?? this.status,
      );

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

  // copywith
  BudgetGoalsListEntity copyWith({
    List<BudgetGoalEntity>? budgetGoals,
    int? total,
    int? page,
    int? totalPages,
  }) =>
      BudgetGoalsListEntity(
        budgetGoals: budgetGoals ?? this.budgetGoals,
        total: total ?? this.total,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );

  @override
  List<Object?> get props => [
        budgetGoals,
        total,
        page,
        totalPages,
      ];
}
