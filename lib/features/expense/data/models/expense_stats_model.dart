import 'package:xpensemate/core/utils/app_logger.dart';

import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';

class ExpenseStatsModel extends ExpenseStatsEntity {
  const ExpenseStatsModel({
    required super.totalSpent,
    required super.dailyAverage,
    required super.spendingVelocityPercent,
    required super.spendingVelocityMessage,
    required super.trackingStreak,
    required super.startDate,
    required super.endDate,
    required super.trend,
    required super.categories,
  });
  factory ExpenseStatsModel.fromEntity(ExpenseStatsEntity entity) =>
      ExpenseStatsModel(
        totalSpent: entity.totalSpent,
        dailyAverage: entity.dailyAverage,
        spendingVelocityPercent: entity.spendingVelocityPercent,
        spendingVelocityMessage: entity.spendingVelocityMessage,
        trackingStreak: entity.trackingStreak,
        startDate: entity.startDate,
        endDate: entity.endDate,
        trend: entity.trend.map(TrendModel.fromEntity).toList(),
        categories:
            entity.categories.map(CategoryStatsModel.fromEntity).toList(),
      );

  factory ExpenseStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json as Map<String, dynamic>? ?? {};

      final trendList = (data['trend'] as List<dynamic>?)
              ?.map((e) => TrendModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      final categoriesList = (data['categories'] as List<dynamic>?)
              ?.map(
                  (e) => CategoryStatsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return ExpenseStatsModel(
        totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
        dailyAverage: (data['dailyAverage'] as num?)?.toDouble() ?? 0.0,
        spendingVelocityPercent:
            (data['spendingVelocityPercent'] as num?)?.toDouble() ?? 0.0,
        spendingVelocityMessage:
            data['spendingVelocityMessage'] as String? ?? '',
        trackingStreak: (data['trackingStreak'] as int?) ?? 0,
        startDate: DateTime.parse(
          data['startDate'] as String? ?? DateTime.now().toIso8601String(),
        ),
        endDate: DateTime.parse(
          data['endDate'] as String? ?? DateTime.now().toIso8601String(),
        ),
        trend: trendList,
        categories: categoriesList,
      );
    } on Exception catch (e) {
      AppLogger.e("error while parsing expenses model => $e");
      throw Exception(e);
    }
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'totalSpent': totalSpent,
          'dailyAverage': dailyAverage,
          'spendingVelocityPercent': spendingVelocityPercent,
          'spendingVelocityMessage': spendingVelocityMessage,
          'trackingStreak': trackingStreak,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'trend': trend.map((e) => (e as TrendModel).toJson()).toList(),
          'categories': categories
              .map((e) => (e as CategoryStatsModel).toJson())
              .toList(),
        },
      };

  ExpenseStatsEntity toEntity() => ExpenseStatsEntity(
        totalSpent: totalSpent,
        dailyAverage: dailyAverage,
        spendingVelocityPercent: spendingVelocityPercent,
        spendingVelocityMessage: spendingVelocityMessage,
        trackingStreak: trackingStreak,
        startDate: startDate,
        endDate: endDate,
        trend: trend,
        categories: categories,
      );
}

class TrendModel extends TrendEntity {
  const TrendModel({
    required super.label,
    required super.amount,
  });
  factory TrendModel.fromEntity(TrendEntity entity) => TrendModel(
        label: entity.label,
        amount: entity.amount,
      );

  factory TrendModel.fromJson(Map<String, dynamic> json) => TrendModel(
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'amount': amount,
      };

  TrendEntity toEntity() => TrendEntity(
        label: label,
        amount: amount,
      );
}

class CategoryStatsModel extends CategoryStatsEntity {
  const CategoryStatsModel({
    required super.category,
    required super.amount,
  });
  factory CategoryStatsModel.fromEntity(CategoryStatsEntity entity) =>
      CategoryStatsModel(
        category: entity.category,
        amount: entity.amount,
      );

  factory CategoryStatsModel.fromJson(Map<String, dynamic> json) =>
      CategoryStatsModel(
        category: json['category'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
      };

  CategoryStatsEntity toEntity() => CategoryStatsEntity(
        category: category,
        amount: amount,
      );
}
