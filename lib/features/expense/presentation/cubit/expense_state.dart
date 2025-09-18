part of 'expense_cubit.dart';

enum ExpenseStates { initial, loading, loaded, error }

class ExpenseState extends Equatable {
  const ExpenseState({
    this.state = ExpenseStates.initial,
    this.expenses,
    this.expenseStats,
    this.budgets,
    this.errorMessage,
    this.stackTrace,
  });

  final ExpenseStates state;
  final ExpensePaginationEntity? expenses;
  final ExpenseStatsEntity? expenseStats;
  final BudgetsListEntity? budgets;
  final String? errorMessage;
  final StackTrace? stackTrace;

  ExpenseState copyWith({
    ExpenseStates? state,
    ExpensePaginationEntity? expenses,
    ExpenseStatsEntity? expenseStats,
    BudgetsListEntity? budgets,
    String? errorMessage,
    StackTrace? stackTrace,
  }) =>
      ExpenseState(
        state: state ?? this.state,
        expenses: expenses ?? this.expenses,
        expenseStats: expenseStats ?? this.expenseStats,
        budgets: budgets ?? this.budgets,
        errorMessage: errorMessage ?? this.errorMessage,
        stackTrace: stackTrace ?? this.stackTrace,
      );

  @override
  List<Object?> get props => [
        state,
        expenses,
        expenseStats,
        budgets,
        errorMessage,
        stackTrace,
      ];
}
