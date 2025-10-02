import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class BudgetGoalsStatsEntity {
  const BudgetGoalsStatsEntity({
    required this.totalGoals,
    required this.activeGoals,
    required this.achievedGoals,
    required this.failedGoals,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.achievementRate,
  });

  final int totalGoals;
  final int activeGoals;
  final int achievedGoals;
  final int failedGoals;
  final double totalBudgeted;
  final double totalSpent;
  final double achievementRate;
}

class GetBudgetGoalsStatsUseCase
    extends UseCase<BudgetGoalsStatsEntity, GetBudgetGoalsStatsParams> {
  GetBudgetGoalsStatsUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalsStatsEntity>> call(
      GetBudgetGoalsStatsParams params) async {
    // Get all budget goals
    final budgetGoalsResult = await repository.getBudgetGoals(
      category: params.category,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
    );

    return budgetGoalsResult.fold(
      Left.new,
      (budgetGoalsList) {
        final budgetGoals = budgetGoalsList.budgetGoals;

        // Calculate statistics
        final totalGoals = budgetGoals.length;
        final activeGoals =
            budgetGoals.where((goal) => goal.status == 'active').length;
        final achievedGoals =
            budgetGoals.where((goal) => goal.status == 'achieved').length;
        final failedGoals =
            budgetGoals.where((goal) => goal.status == 'failed').length;
        final totalBudgeted =
            budgetGoals.fold(0.0, (sum, goal) => sum + goal.amount);
        final totalSpent =
            budgetGoals.fold(0.0, (sum, goal) => sum + goal.currentSpending);
        final achievementRate =
            totalGoals > 0 ? (achievedGoals / totalGoals) * 100 : 0.0;

        return Right(
          BudgetGoalsStatsEntity(
            totalGoals: totalGoals,
            activeGoals: activeGoals,
            achievedGoals: achievedGoals,
            failedGoals: failedGoals,
            totalBudgeted: totalBudgeted,
            totalSpent: totalSpent,
            achievementRate: achievementRate,
          ),
        );
      },
    );
  }
}

class GetBudgetGoalsStatsParams {
  const GetBudgetGoalsStatsParams({
    this.category,
    this.status,
    this.startDate,
    this.endDate,
  });

  final String? category;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
}
