import 'package:xpensemate/features/budget/data/models/budget_goal_model.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';

class BudgetGoalsInsightModel extends BudgetGoalsInsightEntity {
  const BudgetGoalsInsightModel({
    required super.totalGoals,
    required super.activeGoals,
    required super.achievedGoals,
    required super.failedGoals,
    required super.terminatedGoals,
    required super.totalBudgeted,
    required super.avgProgress,
    required super.closestGoals,
    required super.overdueGoals,
  });

  factory BudgetGoalsInsightModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle the case where data is wrapped in a 'data' object
      final data = json['data'] as Map<String, dynamic>? ?? json;

      // If the data contains a "budgetGoals" array, we need to categorize them
      late var allGoals = <BudgetGoalModel>[];
      if (data.containsKey('budgetGoals')) {
        allGoals = _parseBudgetGoalsList(data['budgetGoals'] as List? ?? []);

        // Use the entity's fromGoals method to categorize
        final entity = BudgetGoalsInsightEntity.fromGoals(
          allGoals.map((model) => model.toEntity()).toList(),
        );

        return BudgetGoalsInsightModel.fromEntity(entity);
      }

      // Otherwise, parse the categorized data directly
      return BudgetGoalsInsightModel(
        totalGoals: allGoals.length,
        activeGoals: _parseBudgetGoalsList(data['activeGoals'] as List? ?? []),
        achievedGoals:
            _parseBudgetGoalsList(data['achievedGoals'] as List? ?? []),
        failedGoals: _parseBudgetGoalsList(data['failedGoals'] as List? ?? []),
        terminatedGoals:
            _parseBudgetGoalsList(data['terminatedGoals'] as List? ?? []),
        totalBudgeted: (data['totalBudgeted'] as num?)?.toDouble() ?? 0.0,
        avgProgress: (data['avgProgress'] as num?)?.toDouble() ?? 0.0,
        closestGoals:
            _parseBudgetGoalsList(data['closestGoals'] as List? ?? []),
        overdueGoals:
            _parseBudgetGoalsList(data['overdueGoals'] as List? ?? []),
      );
    } catch (e) {
      // Handle parsing error appropriately
      rethrow;
    }
  }

  factory BudgetGoalsInsightModel.fromEntity(BudgetGoalsInsightEntity entity) =>
      BudgetGoalsInsightModel(
        totalGoals: entity.totalGoals,
        activeGoals:
            entity.activeGoals.map(BudgetGoalModel.fromEntity).toList(),
        achievedGoals:
            entity.achievedGoals.map(BudgetGoalModel.fromEntity).toList(),
        failedGoals:
            entity.failedGoals.map(BudgetGoalModel.fromEntity).toList(),
        terminatedGoals:
            entity.terminatedGoals.map(BudgetGoalModel.fromEntity).toList(),
        totalBudgeted: entity.totalBudgeted,
        avgProgress: entity.avgProgress,
        closestGoals:
            entity.closestGoals.map(BudgetGoalModel.fromEntity).toList(),
        overdueGoals:
            entity.overdueGoals.map(BudgetGoalModel.fromEntity).toList(),
      );

  BudgetGoalsInsightEntity toEntity() => BudgetGoalsInsightEntity(
        totalGoals: totalGoals,
        activeGoals: activeGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
        achievedGoals: achievedGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
        failedGoals: failedGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
        terminatedGoals: terminatedGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
        totalBudgeted: totalBudgeted,
        avgProgress: avgProgress,
        closestGoals: closestGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
        overdueGoals: overdueGoals
            .map((model) => (model as BudgetGoalModel).toEntity())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'totalGoals': totalGoals,
        'activeGoals':
            activeGoals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
        'achievedGoals':
            achievedGoals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
        'failedGoals':
            failedGoals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
        'terminatedGoals': terminatedGoals
            .map((e) => (e as BudgetGoalModel).toJson())
            .toList(),
        'totalBudgeted': totalBudgeted,
        'avgProgress': avgProgress,
        'closestGoals':
            closestGoals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
        'overdueGoals':
            overdueGoals.map((e) => (e as BudgetGoalModel).toJson()).toList(),
      };

  // Getter to get the formatted closest deadline date
  @override
  String get closestDeadlineDate {
    if (closestGoals.isEmpty) {
      return 'N/A';
    }

    // Get the first goal (earliest date) from the sorted list
    final earliestGoal = closestGoals.first;
    return _formatDate(earliestGoal.date);
  }

  // Helper method to format date as "Nov 5, 2025"
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;

    return '$month $day, $year';
  }

  // Helper method to parse budget goals list
  static List<BudgetGoalModel> _parseBudgetGoalsList(List<dynamic> jsonList) {
    try {
      if (jsonList.isEmpty) return [];

      final typedList = jsonList.cast<Map<String, dynamic>>();

      return typedList.map(BudgetGoalModel.fromJson).toList();
    } catch (e) {
      // Handle parsing error appropriately
      rethrow;
    }
  }
}
