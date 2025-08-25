import 'package:equatable/equatable.dart';

// ------------------------------------------------------------------
//  Sub-entities for Budget Goals
// ------------------------------------------------------------------

class BudgetGoalEntity extends Equatable {
  const BudgetGoalEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.setBudget,
    required this.currentSpending,
    required this.priority,
    required this.status,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final double setBudget;
  final double currentSpending;
  final String priority;
  final String status;
  final DateTime date;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    setBudget,
    currentSpending,
    priority,
    status,
    date,
    createdAt,
  ];
}

class PaginationEntity extends Equatable {
  const PaginationEntity({
    required this.currentPage,
    required this.totalPages,
    required this.totalGoals,
  });

  final int currentPage;
  final int totalPages;
  final int totalGoals;

  @override
  List<Object?> get props => [currentPage, totalPages, totalGoals];
}

class BudgetStatsEntity extends Equatable {
  const BudgetStatsEntity({
    required this.totalGoals,
    required this.activeGoals,
    required this.achievedGoals,
    required this.totalBudgeted,
    required this.totalAchievedBudget,
  });

  final int totalGoals;
  final int activeGoals;
  final int achievedGoals;
  final double totalBudgeted;
  final double totalAchievedBudget;

  @override
  List<Object?> get props => [
    totalGoals,
    activeGoals,
    achievedGoals,
    totalBudgeted,
    totalAchievedBudget,
  ];
}

class DateRangeEntity extends Equatable {
  const DateRangeEntity({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

// ------------------------------------------------------------------
//  Main Budget Goals Entity
// ------------------------------------------------------------------

class BudgetGoalsEntity extends Equatable {
  const BudgetGoalsEntity({
    required this.goals,
    required this.pagination,
    required this.stats,
    required this.duration,
    required this.dateRange,
  });

  final List<BudgetGoalEntity> goals;
  final PaginationEntity pagination;
  final BudgetStatsEntity stats;
  final String duration;
  final DateRangeEntity dateRange;

  @override
  List<Object?> get props => [
    goals,
    pagination,
    stats,
    duration,
    dateRange,
  ];
}