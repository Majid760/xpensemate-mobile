part of 'expense_cubit.dart';

enum ExpenseStates {
  initial,
  loading,
  loaded,
  error,
  loadingMore, // New state for loading additional pages
}

enum FilterDefaultValue {
  weekly,
  monthly,
  quarterly,
  yearly,
}

class ExpenseState extends Equatable {
  const ExpenseState({
    this.state = ExpenseStates.initial,
    this.expenses,
    this.expenseStats,
    this.budgets,
    this.message,
    this.filterDefaultValue = FilterDefaultValue.monthly,
    this.stackTrace,
  });

  final ExpenseStates state;
  final ExpensePaginationEntity? expenses;
  final ExpenseStatsEntity? expenseStats;
  final BudgetsListEntity? budgets;
  final String? message;
  final FilterDefaultValue filterDefaultValue;

  final StackTrace? stackTrace;

  ExpenseState copyWith({
    ExpenseStates? state,
    ExpensePaginationEntity? expenses,
    ExpenseStatsEntity? expenseStats,
    BudgetsListEntity? budgets,
    String? message,
    FilterDefaultValue? filterDefaultValue,
    StackTrace? stackTrace,
    int? currentPage,
    bool? hasReachedMax,
    String? paginationError,
  }) =>
      ExpenseState(
        state: state ?? this.state,
        expenses: expenses ?? this.expenses,
        expenseStats: expenseStats ?? this.expenseStats,
        budgets: budgets ?? this.budgets,
        message: message ?? this.message,
        filterDefaultValue: filterDefaultValue ?? this.filterDefaultValue,
        stackTrace: stackTrace ?? this.stackTrace,
      );

  @override
  List<Object?> get props => [
        state,
        expenses,
        expenseStats,
        budgets,
        message,
        stackTrace,
        filterDefaultValue,
      ];

  // Helper getters for UI logic
  bool get isInitialLoading =>
      state == ExpenseStates.loading && expenses == null;
  bool get hasData => expenses != null && expenses!.expenses.isNotEmpty;
  bool get hasError => state == ExpenseStates.error && expenses == null;
}
