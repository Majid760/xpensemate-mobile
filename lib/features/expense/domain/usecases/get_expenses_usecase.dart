import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_pagination_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class GetExpensesUseCase
    implements UseCase<ExpensePaginationEntity, GetExpensesParams> {
  GetExpensesUseCase(this.repository);
  final ExpenseRepository repository;

  @override
  Future<Either<Failure, ExpensePaginationEntity>> call(
    GetExpensesParams params,
  ) async =>
      repository.getExpenses(
        page: params.page,
        limit: params.limit,
      );
}

class GetExpensesParams {
  GetExpensesParams({
    required this.page,
    required this.limit,
  });
  final int page;
  final int limit;
}
