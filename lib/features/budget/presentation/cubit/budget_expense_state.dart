import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_specific_expense_entity.dart';

enum BudgetExpensesStates {
  initial,
  loading,
  loaded,
  error,
  loadingMore, // New state for loading additional pages
}

class BudgetExpensesState extends Equatable {
  const BudgetExpensesState({
    this.state = BudgetExpensesStates.initial,
    this.budgetGoals,
    this.originalBudgetGoals,
    this.message,
    this.stackTrace,
    this.currentPage,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.paginationError,
  });

  final BudgetExpensesStates state;
  final BudgetSpecificExpensesListEntity? budgetGoals; // Filtered expenses
  final BudgetSpecificExpensesListEntity? originalBudgetGoals; // Original unfiltered expenses
  final String? message;
  final StackTrace? stackTrace;

  // Pagination-specific properties
  final int? currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? paginationError;

  BudgetExpensesState copyWith({
    BudgetExpensesStates? state,
    BudgetSpecificExpensesListEntity? budgetGoals,
    BudgetSpecificExpensesListEntity? originalBudgetGoals,
    String? message,
    StackTrace? stackTrace,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? paginationError,
  }) =>
      BudgetExpensesState(
        state: state ?? this.state,
        budgetGoals: budgetGoals ?? this.budgetGoals,
        originalBudgetGoals: originalBudgetGoals ?? this.originalBudgetGoals,
        message: message ?? this.message,
        stackTrace: stackTrace ?? this.stackTrace,
        currentPage: currentPage ?? this.currentPage,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        paginationError: paginationError ?? this.paginationError,
      );

  @override
  List<Object?> get props => [
        state,
        budgetGoals,
        originalBudgetGoals,
        message,
        stackTrace,
        currentPage,
        hasReachedMax,
        isLoadingMore,
        paginationError,
      ];

  // Helper getters for UI logic
  bool get isInitialLoading =>
      state == BudgetExpensesStates.loading && budgetGoals == null;
  bool get hasData => budgetGoals != null && budgetGoals!.expenses.isNotEmpty;
  bool get hasError =>
      state == BudgetExpensesStates.error && budgetGoals == null;
  bool get hasPaginationError => paginationError != null;
  bool get canLoadMore => !hasReachedMax && !isLoadingMore && hasData;
}