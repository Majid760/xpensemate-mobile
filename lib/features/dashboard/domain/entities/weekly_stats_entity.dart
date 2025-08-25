import 'package:equatable/equatable.dart';

// ------------------------------------------------------------------
//  Sub-entities for Weekly Stats
// ------------------------------------------------------------------

class DailyStatsEntity extends Equatable {
  const DailyStatsEntity({
    required this.date,
    required this.total,
  });

  final String date;
  final double total;

  @override
  List<Object?> get props => [date, total];
}

class DayStatsEntity extends Equatable {
  const DayStatsEntity({
    required this.date,
    required this.total,
  });

  final String date;
  final double total;

  @override
  List<Object?> get props => [date, total];
}

// ------------------------------------------------------------------
//  Main Weekly Stats Entity
// ------------------------------------------------------------------

class WeeklyStatsEntity extends Equatable {
  const WeeklyStatsEntity({
    required this.days,
    required this.dailyBreakdown,
    required this.weekTotal,
    required this.balanceLeft,
    required this.weeklyBudget,
    required this.dailyAverage,
    required this.highestDay,
    required this.lowestDay,
  });

  final List<DailyStatsEntity> days;
  final List<DailyStatsEntity> dailyBreakdown;
  final double weekTotal;
  final double balanceLeft;
  final double weeklyBudget;
  final double dailyAverage;
  final DayStatsEntity highestDay;
  final DayStatsEntity lowestDay;

  @override
  List<Object?> get props => [
    days,
    dailyBreakdown,
    weekTotal,
    balanceLeft,
    weeklyBudget,
    dailyAverage,
    highestDay,
    lowestDay,
  ];
}