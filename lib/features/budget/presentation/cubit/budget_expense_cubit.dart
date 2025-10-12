import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget/domain/usecases/get_budget_specific_expenses_usecase.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_state.dart';

class BudgetExpensesCubit extends Cubit<BudgetExpensesState> {
  BudgetExpensesCubit(
    this._getBudgetSpecificExpensesUseCase,
  ) : super(const BudgetExpensesState());

  final GetBudgetSpecificExpensesUseCase _getBudgetSpecificExpensesUseCase;

  // get budget specific expenses
  Future<void> getBudgetSpecificExpenses(
    String budgetId,
  ) async {
    if (state.budgetGoals == null) {
      emit(state.copyWith(state: BudgetExpensesStates.loading));
    }
    final result = await _getBudgetSpecificExpensesUseCase
        .call(GetBudgetSpecificExpensesUseCaseParams(budgetId: budgetId));
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: BudgetExpensesStates.error,
          message: failure.toString(),
        ),
      ),
      (expenses) {
        emit(
          state.copyWith(
            state: BudgetExpensesStates.loaded,
            budgetGoals: expenses,
          ),
        );
      },
    );
  }
}

extension BudgetExpensesCubitX on BuildContext {
  BudgetExpensesCubit get budgetExpensesCubit => read<BudgetExpensesCubit>();
}
