// import logger 
import 'package:xpensemate/core/utils/app_logger.dart';

import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';

// ------------------------------------------------------------------
//  Main Budget Goals Model
// ------------------------------------------------------------------



class BudgetGoalsModel extends BudgetGoalsEntity {
  const BudgetGoalsModel({
    required super.goals,
    required super.pagination,
    required super.stats,
    required super.duration,
    required super.dateRange,
  });

  factory BudgetGoalsModel.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetGoalsModel(
        goals: (json['goals'] as List)
            .map((e) => BudgetGoalModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination:
            PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
        stats: BudgetStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
        duration: json['duration'] as String,
        dateRange:
            DateRangeModel.fromJson(json['dateRange'] as Map<String, dynamic>),
      );
    } catch (e) {
      AppLogger.e("Error parsing BudgetGoalsModel from JSON", e);
      rethrow;
    }
  }

  factory BudgetGoalsModel.fromEntity(BudgetGoalsEntity entity) => BudgetGoalsModel(
      goals: entity.goals
          .map(BudgetGoalModel.fromEntity)
          .toList(),
      pagination: PaginationModel.fromEntity(entity.pagination),
      stats: BudgetStatsModel.fromEntity(entity.stats),
      duration: entity.duration,
      dateRange: DateRangeModel.fromEntity(entity.dateRange),
    );

  BudgetGoalsEntity toEntity() => BudgetGoalsEntity(
      goals: goals,
      pagination: pagination,
      stats: stats,
      duration: duration,
      dateRange: dateRange,
    );

  Map<String, dynamic> toJson() => {
      'goals': goals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
      'stats': (stats as BudgetStatsModel).toJson(),
      'duration': duration,
      'dateRange': (dateRange as DateRangeModel).toJson(),
    };
}



// ------------------------------------------------------------------
//  Sub-models for Budget Goals
// ------------------------------------------------------------------

class BudgetGoalModel extends BudgetGoalEntity {
  const BudgetGoalModel({
    required super.id,
    required super.name,
    required super.category,
    required super.setBudget,
    required super.currentSpending,
    required super.priority,
    required super.status,
    required super.date,
    required super.createdAt,
  });

  factory BudgetGoalModel.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetGoalModel(
        id: json['_id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        setBudget: (json['setBudget'] as num).toDouble(),
        currentSpending: (json['currentSpending'] as num).toDouble(),
        priority: json['priority'] as String,
        status: json['status'] as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    } catch (e) {
      AppLogger.e("Error parsing BudgetGoalModel from JSON", e);
      rethrow;
    }
  }

  factory BudgetGoalModel.fromEntity(BudgetGoalEntity entity) => BudgetGoalModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      setBudget: entity.setBudget,
      currentSpending: entity.currentSpending,
      priority: entity.priority,
      status: entity.status,
      date: entity.date,
      createdAt: entity.createdAt,
    );

  BudgetGoalEntity toEntity() => BudgetGoalEntity(
      id: id,
      name: name,
      category: category,
      setBudget: setBudget,
      currentSpending: currentSpending,
      priority: priority,
      status: status,
      date: date,
      createdAt: createdAt,
    );

  Map<String, dynamic> toJson() => {
      '_id': id,
      'name': name,
      'category': category,
      'setBudget': setBudget,
      'currentSpending': currentSpending,
      'priority': priority,
      'status': status,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
}

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.currentPage,
    required super.totalPages,
    required super.totalGoals,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    try {
      return PaginationModel(
        currentPage: json['currentPage'] as int,
        totalPages: json['totalPages'] as int,
        totalGoals: json['totalGoals'] as int,
      );
    } catch (e) {
      AppLogger.e("Error parsing PaginationModel from JSON", e);
      rethrow;
    }
  }

  factory PaginationModel.fromEntity(PaginationEntity entity) => PaginationModel(
      currentPage: entity.currentPage,
      totalPages: entity.totalPages,
      totalGoals: entity.totalGoals,
    );

  PaginationEntity toEntity() => PaginationEntity(
      currentPage: currentPage,
      totalPages: totalPages,
      totalGoals: totalGoals,
    );

  Map<String, dynamic> toJson() => {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalGoals': totalGoals,
    };
}

class BudgetStatsModel extends BudgetStatsEntity {
  const BudgetStatsModel({
    required super.totalGoals,
    required super.activeGoals,
    required super.achievedGoals,
    required super.totalBudgeted,
    required super.totalAchievedBudget,
  });

  factory BudgetStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetStatsModel(
        totalGoals: json['totalGoals'] as int,
        activeGoals: json['activeGoals'] as int,
        achievedGoals: json['achievedGoals'] as int,
        totalBudgeted: (json['totalBudgeted'] as num).toDouble(),
        totalAchievedBudget: (json['totalAchievedBudget'] as num).toDouble(),
      );
    } catch (e) {
      AppLogger.e("Error parsing BudgetStatsModel from JSON", e);
      rethrow;
    }
  }

  factory BudgetStatsModel.fromEntity(BudgetStatsEntity entity) => BudgetStatsModel(
      totalGoals: entity.totalGoals,
      activeGoals: entity.activeGoals,
      achievedGoals: entity.achievedGoals,
      totalBudgeted: entity.totalBudgeted,
      totalAchievedBudget: entity.totalAchievedBudget,
    );

  BudgetStatsEntity toEntity() => BudgetStatsEntity(
      totalGoals: totalGoals,
      activeGoals: activeGoals,
      achievedGoals: achievedGoals,
      totalBudgeted: totalBudgeted,
      totalAchievedBudget: totalAchievedBudget,
    );

  Map<String, dynamic> toJson() => {
      'totalGoals': totalGoals,
      'activeGoals': activeGoals,
      'achievedGoals': achievedGoals,
      'totalBudgeted': totalBudgeted,
      'totalAchievedBudget': totalAchievedBudget,
    };
}

class DateRangeModel extends DateRangeEntity {
  const DateRangeModel({
    required super.startDate,
    required super.endDate,
  });

  factory DateRangeModel.fromJson(Map<String, dynamic> json) {
    try {
      return DateRangeModel(
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
      );
    } catch (e) {
      AppLogger.e("Error parsing DateRangeModel from JSON", e);
      rethrow;
    }
  }

  factory DateRangeModel.fromEntity(DateRangeEntity entity) => DateRangeModel(
      startDate: entity.startDate,
      endDate: entity.endDate,
    );

  DateRangeEntity toEntity() => DateRangeEntity(
      startDate: startDate,
      endDate: endDate,
    );

  Map<String, dynamic> toJson() => {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
}

