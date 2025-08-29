import 'package:xpensemate/core/utils/app_logger.dart';

import 'package:xpensemate/features/dashboard/domain/entities/weekly_stats_entity.dart';

// ------------------------------------------------------------------
//  Sub-models for Weekly Stats
// ------------------------------------------------------------------

class DailyStatsModel extends DailyStatsEntity {
  const DailyStatsModel({
    required super.date,
    required super.total,
  });

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return DailyStatsModel(
        date: json['date'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      AppLogger.e("Error parsing DailyStatsModel from JSON", e);
      rethrow;
    }
  }

  factory DailyStatsModel.fromEntity(DailyStatsEntity entity) => DailyStatsModel(
      date: entity.date,
      total: entity.total,
    );

  DailyStatsEntity toEntity() => DailyStatsEntity(
      date: date,
      total: total,
    );

  Map<String, dynamic> toJson() => {
      'date': date,
      'total': total,
    };
}

class DayStatsModel extends DayStatsEntity {
  const DayStatsModel({
    required super.date,
    required super.total,
  });

  factory DayStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return DayStatsModel(
        date: json['date'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      AppLogger.e("Error parsing DayStatsModel from JSON", e);
      rethrow;
    }
  }

  factory DayStatsModel.fromEntity(DayStatsEntity entity) => DayStatsModel(
      date: entity.date,
      total: entity.total,
    );

  DayStatsEntity toEntity() => DayStatsEntity(
      date: date,
      total: total,
    );

  Map<String, dynamic> toJson() => {
      'date': date,
      'total': total,
    };
}

// ------------------------------------------------------------------
//  Main Weekly Stats Model
// ------------------------------------------------------------------

class WeeklyStatsModel extends WeeklyStatsEntity {
  const WeeklyStatsModel({
    required super.days,
    required super.dailyBreakdown,
    required super.weekTotal,
    required super.balanceLeft,
    required super.weeklyBudget,
    required super.dailyAverage,
    required super.highestDay,
    required super.lowestDay,
  });

  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      AppLogger.d("Parsing WeeklyStatsModel from JSON: ${json.toString()}");
      
      // Check if this is a wrapped response (with type, title, message, data)
      // or a direct response
      Map<String, dynamic> actualData;
      if (json.containsKey('data') && json.containsKey('type')) {
        // This is a wrapped response, extract the actual data
        actualData = json['data'] as Map<String, dynamic>? ?? {};
        AppLogger.d("Found wrapped response, extracting data: ${actualData.toString()}");
      } else {
        // This is a direct response
        actualData = json;
        AppLogger.d("Direct response format detected");
      }
      
      return WeeklyStatsModel(
        days: (actualData['days'] as List? ?? [])
            .map((e) => DailyStatsModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        dailyBreakdown: (actualData['dailyBreakdown'] as List? ?? [])
            .map((e) => DailyStatsModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        weekTotal: (actualData['weekTotal'] as num?)?.toDouble() ?? 0.0,
        balanceLeft: (actualData['balanceLeft'] as num?)?.toDouble() ?? 0.0,
        weeklyBudget: (actualData['weeklyBudget'] as num?)?.toDouble() ?? 0.0,
        dailyAverage: (actualData['dailyAverage'] as num?)?.toDouble() ?? 0.0,
        highestDay: actualData['highestDay'] != null
            ? DayStatsModel.fromJson(actualData['highestDay'] as Map<String, dynamic>)
            : const DayStatsModel(date: '', total: 0.0),
        lowestDay: actualData['lowestDay'] != null
            ? DayStatsModel.fromJson(actualData['lowestDay'] as Map<String, dynamic>)
            : const DayStatsModel(date: '', total: 0.0),
      );
    } catch (e) {
      AppLogger.e("Error parsing WeeklyStatsModel from JSON: ${json.toString()}", e);
      rethrow;
    }
  }

  factory WeeklyStatsModel.fromEntity(WeeklyStatsEntity entity) => WeeklyStatsModel(
      days: entity.days
          .map(DailyStatsModel.fromEntity)
          .toList(),
      dailyBreakdown: entity.dailyBreakdown
          .map(DailyStatsModel.fromEntity)
          .toList(),
      weekTotal: entity.weekTotal,
      balanceLeft: entity.balanceLeft,
      weeklyBudget: entity.weeklyBudget,
      dailyAverage: entity.dailyAverage,
      highestDay: DayStatsModel.fromEntity(entity.highestDay),
      lowestDay: DayStatsModel.fromEntity(entity.lowestDay),
    );

  WeeklyStatsEntity toEntity() => WeeklyStatsEntity(
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
      'days': days.map((e) => (e as DailyStatsModel).toJson()).toList(),
      'dailyBreakdown': dailyBreakdown
          .map((e) => (e as DailyStatsModel).toJson())
          .toList(),
      'weekTotal': weekTotal,
      'balanceLeft': balanceLeft,
      'weeklyBudget': weeklyBudget,
      'dailyAverage': dailyAverage,
      'highestDay': (highestDay as DayStatsModel).toJson(),
      'lowestDay': (lowestDay as DayStatsModel).toJson(),
    };
}