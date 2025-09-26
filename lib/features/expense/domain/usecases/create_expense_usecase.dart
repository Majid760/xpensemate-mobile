import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class CreateExpensesUseCase implements UseCase<bool, CreateExpensesParams> {
  CreateExpensesUseCase(this.repository);
  final ExpenseRepository repository;

  @override
  Future<Either<Failure, bool>> call(
    CreateExpensesParams params,
  ) async =>
      repository.createExpense(
        expense: params.expenseEntity,
      );
}

class CreateExpensesParams {
  CreateExpensesParams({
    required this.expenseEntity,
  });
  final ExpenseEntity expenseEntity;
}
