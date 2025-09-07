import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class GetExpenseStatsUseCase
    implements UseCase<ExpenseStatsEntity, GetExpenseStatsParams> {
  GetExpenseStatsUseCase(this.repository);
  final ExpenseRepository repository;

  @override
  Future<Either<Failure, ExpenseStatsEntity>> call(
    GetExpenseStatsParams params,
  ) async =>
      repository.getExpenseStats(
        period: params.period,
      );
}

class GetExpenseStatsParams {
  GetExpenseStatsParams({
    this.period,
  });
  final String? period;
}
