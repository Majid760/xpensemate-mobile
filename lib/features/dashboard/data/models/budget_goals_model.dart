// import logger
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/expense/data/models/budgets_model.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budgets_list_entity.dart';

class BudgetsListModel extends BudgetsListEntity {
  const BudgetsListModel({
    required super.budgets,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory BudgetsListModel.fromJson(Map<String, dynamic> json) =>
      BudgetsListModel(
        budgets: (json['data'] as List? ?? [])
            .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        totalPages: json['totalPages'] as int? ?? 1,
      );

  factory BudgetsListModel.fromEntity(BudgetsListEntity entity) =>
      BudgetsListModel(
        budgets: entity.budgets,
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  BudgetsListEntity toEntity() => BudgetsListEntity(
        budgets: budgets,
        total: total,
        page: page,
        totalPages: totalPages,
      );

  Map<String, dynamic> toJson() => {
        'data': budgets.map((e) => (e as BudgetModel).toJson()).toList(),
        'total': total,
        'page': page,
        'totalPages': totalPages,
      };
}

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
      Map<String, dynamic> actualData;
      if (json.containsKey('data') && json.containsKey('type')) {
        // This is a wrapped response, extract the actual data
        actualData = json['data'] as Map<String, dynamic>? ?? {};
        AppLogger.d(
          "Found wrapped response, extracting data: $actualData",
        );
      } else {
        actualData = json;
        AppLogger.d("Direct response format detected");
      }

      return BudgetGoalsModel(
        goals: (actualData['goals'] as List? ?? [])
            .map((e) => BudgetGoalModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination: actualData['pagination'] != null
            ? PaginationModel.fromJson(
                actualData['pagination'] as Map<String, dynamic>,
              )
            : const PaginationModel(
                currentPage: 1,
                totalPages: 1,
                totalGoals: 0,
              ),
        stats: actualData['stats'] != null
            ? BudgetStatsModel.fromJson(
                actualData['stats'] as Map<String, dynamic>,
              )
            : const BudgetStatsModel(
                totalGoals: 0,
                activeGoals: 0,
                achievedGoals: 0,
                totalBudgeted: 0,
                totalAchievedBudget: 0,
              ),
        duration: actualData['duration'] as String? ?? '',
        dateRange: actualData['dateRange'] != null
            ? DateRangeModel.fromJson(
                actualData['dateRange'] as Map<String, dynamic>,
              )
            : DateRangeModel(
                startDate: DateTime.now(),
                endDate: DateTime.now(),
              ),
      );
    } catch (e) {
      AppLogger.e(
        "Error parsing BudgetGoalsModel from JSON: $json",
        e,
      );
      rethrow;
    }
  }

  factory BudgetGoalsModel.fromEntity(BudgetGoalsEntity entity) =>
      BudgetGoalsModel(
        goals: entity.goals.map(BudgetGoalModel.fromEntity).toList(),
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
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        setBudget: (json['setBudget'] as num?)?.toDouble() ?? 0.0,
        currentSpending: (json['currentSpending'] as num?)?.toDouble() ?? 0.0,
        priority: json['priority'] as String? ?? '',
        status: json['status'] as String? ?? '',
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      AppLogger.e("Error parsing BudgetGoalModel from JSON", e);
      rethrow;
    }
  }

  factory BudgetGoalModel.fromEntity(BudgetGoalEntity entity) =>
      BudgetGoalModel(
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
        currentPage: json['currentPage'] as int? ?? 1,
        totalPages: json['totalPages'] as int? ?? 1,
        totalGoals: json['totalGoals'] as int? ?? 0,
      );
    } catch (e) {
      AppLogger.e("Error parsing PaginationModel from JSON", e);
      rethrow;
    }
  }

  factory PaginationModel.fromEntity(PaginationEntity entity) =>
      PaginationModel(
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
        totalGoals: json['totalGoals'] as int? ?? 0,
        activeGoals: json['activeGoals'] as int? ?? 0,
        achievedGoals: json['achievedGoals'] as int? ?? 0,
        totalBudgeted: (json['totalBudgeted'] as num?)?.toDouble() ?? 0.0,
        totalAchievedBudget:
            (json['totalAchievedBudget'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      AppLogger.e("Error parsing BudgetStatsModel from JSON", e);
      rethrow;
    }
  }

  factory BudgetStatsModel.fromEntity(BudgetStatsEntity entity) =>
      BudgetStatsModel(
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
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'] as String) ?? DateTime.now()
            : DateTime.now(),
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
