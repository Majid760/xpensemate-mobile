import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class GetExpensesUseCase implements UseCase<ExpensePaginationEntity, GetExpensesParams> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, ExpensePaginationEntity>> call(GetExpensesParams params) async {
    return await repository.getExpenses(
      page: params.page,
      limit: params.limit,
      startDate: params.startDate,
      endDate: params.endDate,
      categoryId: params.categoryId,
      sortBy: params.sortBy,
      ascending: params.ascending,
    );
  }
}

class GetExpensesParams {
  final int page;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final String? sortBy;
  final bool? ascending;

  GetExpensesParams({
    required this.page,
    required this.limit,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.sortBy,
    this.ascending,
  });
}