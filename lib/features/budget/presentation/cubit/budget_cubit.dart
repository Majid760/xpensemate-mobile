import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget/domain/usecases/usecase_export.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(
    this._getBudgetGoalsUseCase,
    this._createBudgetGoalUseCase,
    this._updateBudgetGoalUseCase,
    this._deleteBudgetGoalUseCase,
    this._budgetGoalsStatsUseCase,
  ) : super(const BudgetState()) {
    getBudgetGoals();
  }
  final GetBudgetGoalsByCategoryUseCase _getBudgetGoalsUseCase;
  final CreateBudgetGoalUseCase _createBudgetGoalUseCase;
  final UpdateBudgetGoalUseCase _updateBudgetGoalUseCase;
  final DeleteBudgetGoalUseCase _deleteBudgetGoalUseCase;
  final GetBudgetGoalsStatsUseCase _budgetGoalsStatsUseCase;

  Future<void> getBudgetGoals() async {
    final result =
        await _getBudgetGoalsUseCase.call(const GetBudgetGoalsByCategoryParams(
      page: 1,
      limit: 10,
    ));
    result.fold((failure) {
      emit(state.copyWith(errorMessage: failure.message));
      print('wow this is ererr====> $failure');
    }, (budgetGoals) {
      print('this is budget goals ====> ${budgetGoals.budgetGoals.length}');
      emit(state.copyWith(budgetGoals: budgetGoals));
    });
  }
}
