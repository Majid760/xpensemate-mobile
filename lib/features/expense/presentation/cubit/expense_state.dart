part of 'expense_cubit.dart';

enum ExpenseStates {
  initial,
  loading,
  loaded,
  error,
  loadingMore, // New state for loading additional pages
}

class ExpenseState extends Equatable {
  const ExpenseState({
    this.state = ExpenseStates.initial,
    this.expenses,
    this.expenseStats,
    this.budgets,
    this.errorMessage,
    this.stackTrace,
    this.currentPage,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.paginationError,
  });

  final ExpenseStates state;
  final ExpensePaginationEntity? expenses;
  final ExpenseStatsEntity? expenseStats;
  final BudgetsListEntity? budgets;
  final String? errorMessage;
  final StackTrace? stackTrace;

  // Pagination-specific properties
  final int? currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? paginationError; // Separate error for pagination failures

  ExpenseState copyWith({
    ExpenseStates? state,
    ExpensePaginationEntity? expenses,
    ExpenseStatsEntity? expenseStats,
    BudgetsListEntity? budgets,
    String? errorMessage,
    StackTrace? stackTrace,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? paginationError,
  }) =>
      ExpenseState(
        state: state ?? this.state,
        expenses: expenses ?? this.expenses,
        expenseStats: expenseStats ?? this.expenseStats,
        budgets: budgets ?? this.budgets,
        errorMessage: errorMessage ?? this.errorMessage,
        stackTrace: stackTrace ?? this.stackTrace,
        currentPage: currentPage ?? this.currentPage,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        paginationError: paginationError ?? this.paginationError,
      );

  @override
  List<Object?> get props => [
        state,
        expenses,
        expenseStats,
        budgets,
        errorMessage,
        stackTrace,
        currentPage,
        hasReachedMax,
        isLoadingMore,
        paginationError,
      ];

  // Helper getters for UI logic
  bool get isInitialLoading =>
      state == ExpenseStates.loading && expenses == null;
  bool get hasData => expenses != null && expenses!.expenses.isNotEmpty;
  bool get hasError => state == ExpenseStates.error && expenses == null;
  bool get hasPaginationError => paginationError != null;
  bool get canLoadMore => !hasReachedMax && !isLoadingMore && hasData;
}
