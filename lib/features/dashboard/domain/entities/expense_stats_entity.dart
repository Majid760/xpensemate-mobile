import 'package:equatable/equatable.dart';

// ------------------------------------------------------------------
//  Sub-entities for Expense Stats
// ------------------------------------------------------------------

class DailyExpenseEntity extends Equatable {
  const DailyExpenseEntity({
    required this.date,
    required this.total,
  });

  final String date;
  final double total;

  @override
  List<Object?> get props => [date, total];
}

class DayExpenseEntity extends Equatable {
  const DayExpenseEntity({
    required this.date,
    required this.total,
  });

  final String date;
  final double total;

  @override
  List<Object?> get props => [date, total];
}

// ------------------------------------------------------------------
//  Main Expense Stats Entity
// ------------------------------------------------------------------

class ExpenseStatsEntity extends Equatable {
  const ExpenseStatsEntity({
    required this.days,
    required this.dailyBreakdown,
    required this.weekTotal,
    required this.balanceLeft,
    required this.weeklyBudget,
    required this.dailyAverage,
    required this.highestDay,
    required this.lowestDay,
  });

  final List<DailyExpenseEntity> days;
  final List<DailyExpenseEntity> dailyBreakdown;
  final double weekTotal;
  final double balanceLeft;
  final double weeklyBudget;
  final double dailyAverage;
  final DayExpenseEntity highestDay;
  final DayExpenseEntity lowestDay;

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