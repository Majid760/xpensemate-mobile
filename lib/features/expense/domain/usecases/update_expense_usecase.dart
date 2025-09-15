import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  UpdateExpenseUseCase(this.repository);
  final ExpenseRepository repository;

  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity expense) async =>
      repository.updateExpense(expense);
}
