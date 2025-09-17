import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/expense/domain/entities/budgets_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
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
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetModel(
        id: json['_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        category: json['category'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        status: json['status'] as String? ?? '',
        priority: json['priority'] as String? ?? '',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        isDeleted: json['is_deleted'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      );
    } on Exception catch (e) {
      AppLogger.e('Failed to parse BudgetModel from json: $e');
      rethrow;
    }
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) => BudgetModel(
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
      );

  BudgetEntity toEntity() => BudgetEntity(
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
      };
}
