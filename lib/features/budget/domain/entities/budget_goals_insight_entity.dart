import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';

class BudgetGoalsInsightEntity extends Equatable {
  const BudgetGoalsInsightEntity({
    this.totalGoals = 0,
    required this.activeGoals,
    required this.achievedGoals,
    required this.failedGoals,
    required this.terminatedGoals,
    required this.totalBudgeted,
    required this.avgProgress,
    required this.closestGoals,
    required this.overdueGoals,
    required this.goals,
  });

  factory BudgetGoalsInsightEntity.fromGoals(List<BudgetGoalEntity> goals) {
    final activeGoals = <BudgetGoalEntity>[];
    final achievedGoals = <BudgetGoalEntity>[];
    final failedGoals = <BudgetGoalEntity>[];
    final terminatedGoals = <BudgetGoalEntity>[];
    final closestGoals = <BudgetGoalEntity>[];
    final overdueGoals = <BudgetGoalEntity>[];
    double totalBudgeted = 0;
    double progressSum = 0;
    var achievedCount = 0;
    final now = DateTime.now();

    // Single loop through all goals
    for (final goal in goals) {
      // Categorize by status
      switch (goal.status) {
        case 'active':
          activeGoals.add(goal);
          totalBudgeted += goal.amount;
          break;
        case 'achieved':
          achievedGoals.add(goal);
          progressSum += goal.progress.toDouble();
          achievedCount++;
          break;
        case 'failed':
          failedGoals.add(goal);
          break;
        case 'terminated':
          terminatedGoals.add(goal);
          break;
        default:
          break;
      }

      // Check for closest goals (all goals with a date, to be sorted by date)
      closestGoals.add(goal);

      // Check for overdue goals (date is before now and not in completed statuses)
      if (goal.date.isBefore(now) &&
          !['achieved', 'terminated', 'failed'].contains(goal.status)) {
        overdueGoals.add(goal);
      }
    }

    // Sort closest goals by date (all goals with dates)
    closestGoals.sort((a, b) => a.date.compareTo(b.date));

    // Calculate average progress
    final avgProgress = achievedCount > 0 ? progressSum / achievedCount : 0.0;

    return BudgetGoalsInsightEntity(
      totalGoals: goals.length,
      activeGoals: activeGoals,
      achievedGoals: achievedGoals,
      failedGoals: failedGoals,
      terminatedGoals: terminatedGoals,
      totalBudgeted: totalBudgeted,
      avgProgress: avgProgress,
      closestGoals: closestGoals,
      overdueGoals: overdueGoals,
      goals: goals,
    );
  }
  final int totalGoals;
  final List<BudgetGoalEntity> activeGoals;
  final List<BudgetGoalEntity> achievedGoals;
  final List<BudgetGoalEntity> failedGoals;
  final List<BudgetGoalEntity> terminatedGoals;
  final double totalBudgeted;
  final double avgProgress;
  final List<BudgetGoalEntity> closestGoals;
  final List<BudgetGoalEntity> overdueGoals;
  final List<BudgetGoalEntity> goals;

  // Getter to get the formatted closest deadline date
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
      'Dec'
    ];

    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;

    return '$month $day, $year';
  }

  @override
  List<Object?> get props => [
        totalGoals,
        activeGoals,
        achievedGoals,
        failedGoals,
        terminatedGoals,
        totalBudgeted,
        avgProgress,
        closestGoals,
        overdueGoals,
        goals,
      ];

  BudgetGoalsInsightEntity copyWith({
    int totalGoals = 0,
    List<BudgetGoalEntity>? activeGoals,
    List<BudgetGoalEntity>? achievedGoals,
    List<BudgetGoalEntity>? failedGoals,
    List<BudgetGoalEntity>? terminatedGoals,
    double? totalBudgeted,
    double? avgProgress,
    List<BudgetGoalEntity>? closestGoals,
    List<BudgetGoalEntity>? overdueGoals,
    List<BudgetGoalEntity>? goals,
  }) =>
      BudgetGoalsInsightEntity(
        totalGoals: totalGoals,
        activeGoals: activeGoals ?? this.activeGoals,
        achievedGoals: achievedGoals ?? this.achievedGoals,
        failedGoals: failedGoals ?? this.failedGoals,
        terminatedGoals: terminatedGoals ?? this.terminatedGoals,
        totalBudgeted: totalBudgeted ?? this.totalBudgeted,
        avgProgress: avgProgress ?? this.avgProgress,
        closestGoals: closestGoals ?? this.closestGoals,
        overdueGoals: overdueGoals ?? this.overdueGoals,
        goals: goals ?? this.goals,
      );
}
