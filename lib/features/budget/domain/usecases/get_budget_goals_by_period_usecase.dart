import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetGoalsByPeriodUseCase
    extends UseCase<BudgetGoalsInsightEntity, GetBudgetGoalsByPeriodParams> {
  GetBudgetGoalsByPeriodUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalsInsightEntity>> call(
    GetBudgetGoalsByPeriodParams params,
  ) =>
      repository.getBudgetGoalsByPeriod(
        period: params.period,
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class GetBudgetGoalsByPeriodParams {
  const GetBudgetGoalsByPeriodParams({
    required this.period,
    this.startDate,
    this.endDate,
  });

  final String period;

  final DateTime? startDate;
  final DateTime? endDate;
}
