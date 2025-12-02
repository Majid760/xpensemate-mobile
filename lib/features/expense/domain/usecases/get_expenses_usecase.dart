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
        filterQuery: params.filterQuery,
        limit: params.limit,
      );
}

class GetExpensesParams {
  GetExpensesParams({
    required this.page,
    required this.limit,
    this.filterQuery,
  });
  final int page;
  String? filterQuery;
  final int limit;
}
