import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class GetExpenseStatsUseCase implements UseCase<ExpenseStatsEntity, GetExpenseStatsParams> {
  final ExpenseRepository repository;

  GetExpenseStatsUseCase(this.repository);

  @override
  Future<Either<Failure, ExpenseStatsEntity>> call(GetExpenseStatsParams params) async {
    return await repository.getExpenseStats(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetExpenseStatsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  GetExpenseStatsParams({
    this.startDate,
    this.endDate,
  });
}