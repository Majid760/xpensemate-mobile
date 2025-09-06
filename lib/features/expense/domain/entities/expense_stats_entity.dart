import 'package:equatable/equatable.dart';

class ExpenseStatsEntity extends Equatable {
  final double totalSpent;
  final double dailyAverage;
  final double spendingVelocityPercent;
  final String spendingVelocityMessage;
  final int trackingStreak;
  final DateTime startDate;
  final DateTime endDate;
  final List<TrendEntity> trend;
  final List<CategoryStatsEntity> categories;

  const ExpenseStatsEntity({
    required this.totalSpent,
    required this.dailyAverage,
    required this.spendingVelocityPercent,
    required this.spendingVelocityMessage,
    required this.trackingStreak,
    required this.startDate,
    required this.endDate,
    required this.trend,
    required this.categories,
  });

  ExpenseStatsEntity copyWith({
    double? totalSpent,
    double? dailyAverage,
    double? spendingVelocityPercent,
    String? spendingVelocityMessage,
    int? trackingStreak,
    DateTime? startDate,
    DateTime? endDate,
    List<TrendEntity>? trend,
    List<CategoryStatsEntity>? categories,
  }) =>
      ExpenseStatsEntity(
        totalSpent: totalSpent ?? this.totalSpent,
        dailyAverage: dailyAverage ?? this.dailyAverage,
        spendingVelocityPercent:
            spendingVelocityPercent ?? this.spendingVelocityPercent,
        spendingVelocityMessage:
            spendingVelocityMessage ?? this.spendingVelocityMessage,
        trackingStreak: trackingStreak ?? this.trackingStreak,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        trend: trend ?? this.trend,
        categories: categories ?? this.categories,
      );

  @override
  List<Object?> get props => [
        totalSpent,
        dailyAverage,
        spendingVelocityPercent,
        spendingVelocityMessage,
        trackingStreak,
        startDate,
        endDate,
        trend,
        categories,
      ];
}

class TrendEntity extends Equatable {
  final String label;
  final double amount;

  const TrendEntity({
    required this.label,
    required this.amount,
  });

  TrendEntity copyWith({
    String? label,
    double? amount,
  }) =>
      TrendEntity(
        label: label ?? this.label,
        amount: amount ?? this.amount,
      );

  @override
  List<Object?> get props => [label, amount];
}

class CategoryStatsEntity extends Equatable {
  final String category;
  final double amount;

  const CategoryStatsEntity({
    required this.category,
    required this.amount,
  });

  CategoryStatsEntity copyWith({
    String? category,
    double? amount,
  }) =>
      CategoryStatsEntity(
        category: category ?? this.category,
        amount: amount ?? this.amount,
      );

  @override
  List<Object?> get props => [category, amount];
}