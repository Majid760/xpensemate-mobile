import 'package:xpensemate/core/utils/app_logger.dart';

import 'package:xpensemate/features/dashboard/domain/entities/expense_stats_entity.dart';

// ------------------------------------------------------------------
//  Sub-models for Expense Stats
// ------------------------------------------------------------------

class DailyExpenseModel extends DailyExpenseEntity {
  const DailyExpenseModel({
    required super.date,
    required super.total,
  });

  factory DailyExpenseModel.fromJson(Map<String, dynamic> json) {
    try {
      return DailyExpenseModel(
        date: json['date'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      AppLogger.e("Error parsing DailyExpenseModel from JSON", e);
      rethrow;
    }
  }

  factory DailyExpenseModel.fromEntity(DailyExpenseEntity entity) => DailyExpenseModel(
      date: entity.date,
      total: entity.total,
    );

  DailyExpenseEntity toEntity() => DailyExpenseEntity(
      date: date,
      total: total,
    );

  Map<String, dynamic> toJson() => {
      'date': date,
      'total': total,
    };
}

class DayExpenseModel extends DayExpenseEntity {
  const DayExpenseModel({
    required super.date,
    required super.total,
  });

  factory DayExpenseModel.fromJson(Map<String, dynamic> json) {
    try {
      return DayExpenseModel(
        date: json['date'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      AppLogger.e("Error parsing DayExpenseModel from JSON", e);
      rethrow;
    }
  }

  factory DayExpenseModel.fromEntity(DayExpenseEntity entity) => DayExpenseModel(
      date: entity.date,
      total: entity.total,
    );

  DayExpenseEntity toEntity() => DayExpenseEntity(
      date: date,
      total: total,
    );

  Map<String, dynamic> toJson() => {
      'date': date,
      'total': total,
    };
}

// ------------------------------------------------------------------
//  Main Expense Stats Model
// ------------------------------------------------------------------

class ExpenseStatsModel extends ExpenseStatsEntity {
  const ExpenseStatsModel({
    required super.days,
    required super.dailyBreakdown,
    required super.weekTotal,
    required super.balanceLeft,
    required super.weeklyBudget,
    required super.dailyAverage,
    required super.highestDay,
    required super.lowestDay,
  });

  factory ExpenseStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpenseStatsModel(
        days: (json['days'] as List? ?? [])
            .map((e) => DailyExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        dailyBreakdown: (json['dailyBreakdown'] as List? ?? [])
            .map((e) => DailyExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        weekTotal: (json['weekTotal'] as num?)?.toDouble() ?? 0.0,
        balanceLeft: (json['balanceLeft'] as num?)?.toDouble() ?? 0.0,
        weeklyBudget: (json['weeklyBudget'] as num?)?.toDouble() ?? 0.0,
        dailyAverage: (json['dailyAverage'] as num?)?.toDouble() ?? 0.0,
        highestDay: json['highestDay'] != null
            ? DayExpenseModel.fromJson(json['highestDay'] as Map<String, dynamic>)
            : const DayExpenseModel(date: '', total: 0.0),
        lowestDay: json['lowestDay'] != null
            ? DayExpenseModel.fromJson(json['lowestDay'] as Map<String, dynamic>)
            : const DayExpenseModel(date: '', total: 0.0),
      );
    } catch (e) {
      AppLogger.e("Error parsing ExpenseStatsModel from JSON", e);
      rethrow;
    }
  }

  factory ExpenseStatsModel.fromEntity(ExpenseStatsEntity entity) => ExpenseStatsModel(
      days: entity.days
          .map(DailyExpenseModel.fromEntity)
          .toList(),
      dailyBreakdown: entity.dailyBreakdown
          .map(DailyExpenseModel.fromEntity)
          .toList(),
      weekTotal: entity.weekTotal,
      balanceLeft: entity.balanceLeft,
      weeklyBudget: entity.weeklyBudget,
      dailyAverage: entity.dailyAverage,
      highestDay: DayExpenseModel.fromEntity(entity.highestDay),
      lowestDay: DayExpenseModel.fromEntity(entity.lowestDay),
    );

  ExpenseStatsEntity toEntity() => ExpenseStatsEntity(
      days: days,
      dailyBreakdown: dailyBreakdown,
      weekTotal: weekTotal,
      balanceLeft: balanceLeft,
      weeklyBudget: weeklyBudget,
      dailyAverage: dailyAverage,
      highestDay: highestDay,
      lowestDay: lowestDay,
    );

  Map<String, dynamic> toJson() => {
      'days': days.map((e) => (e as DailyExpenseModel).toJson()).toList(),
      'dailyBreakdown': dailyBreakdown
          .map((e) => (e as DailyExpenseModel).toJson())
          .toList(),
      'weekTotal': weekTotal,
      'balanceLeft': balanceLeft,
      'weeklyBudget': weeklyBudget,
      'dailyAverage': dailyAverage,
      'highestDay': (highestDay as DayExpenseModel).toJson(),
      'lowestDay': (lowestDay as DayExpenseModel).toJson(),
    };
}