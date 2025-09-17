import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budgets_list_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class GetBudgetsUseCase extends UseCase<BudgetsListEntity, GetBudgetsParams> {
  GetBudgetsUseCase(this.repository);

  final ExpenseRepository repository;

  @override
  Future<Either<Failure, BudgetsListEntity>> call(GetBudgetsParams params) =>
      repository.getBudgets(
        page: params.page,
        limit: params.limit,
        status: params.status,
      );
}

class GetBudgetsParams {
  const GetBudgetsParams({
    this.page,
    this.limit,
    this.status,
  });

  final int? page;
  final int? limit;
  final String? status;
}
