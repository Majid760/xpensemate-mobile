import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetsGoalsUseCase
    extends UseCase<BudgetGoalsListEntity, GetBudgetGoalsParams> {
  GetBudgetsGoalsUseCase(this.repository);

  final BudgetRepository repository;

  @override
  Future<Either<Failure, BudgetGoalsListEntity>> call(
    GetBudgetGoalsParams params,
  ) =>
      repository.getBudgetGoals(
        page: params.page,
        limit: params.limit,
        category: params.category,
        status: params.status,
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class GetBudgetGoalsParams {
  const GetBudgetGoalsParams({
    this.page,
    this.limit,
    this.category,
    this.status,
    this.startDate,
    this.endDate,
  });

  final int? page;
  final int? limit;
  final String? category;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
}
