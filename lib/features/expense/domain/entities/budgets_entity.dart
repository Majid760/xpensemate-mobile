import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  const BudgetEntity({
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
  final double progress;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double remainingBalance;

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
      ];

  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    DateTime? date,
    String? category,
    String? detail,
    String? status,
    String? priority,
    double? progress,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? remainingBalance,
  }) =>
      BudgetEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        category: category ?? this.category,
        detail: detail ?? this.detail,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        progress: progress ?? this.progress,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        remainingBalance: remainingBalance ?? this.remainingBalance,
      );
}
