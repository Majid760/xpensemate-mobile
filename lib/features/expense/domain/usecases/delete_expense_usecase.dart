import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  DeleteExpenseUseCase(this.repository);
  final ExpenseRepository repository;

  Future<Either<Failure, bool>> call(String expenseId) async =>
      repository.deleteExpense(expenseId);
}
