import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';

enum BudgetStates {
  initial,
  loading,
  loaded,
  error,
  loadingMore, // New state for loading additional pages
}

class BudgetState extends Equatable {
  const BudgetState({
    this.state = BudgetStates.initial,
    this.budgetGoals,
    this.budgetGoalsInsight,
    this.defaultPeriod = FilterDefaultValue.monthly,
    this.message,
    this.stackTrace,
    this.currentPage,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.paginationError,
  });

  final BudgetStates state;
  final BudgetGoalsListEntity? budgetGoals;
  final BudgetGoalsInsightEntity? budgetGoalsInsight;
  final FilterDefaultValue defaultPeriod;
  final String? message;
  final StackTrace? stackTrace;

  // Pagination-specific properties
  final int? currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? paginationError;

  BudgetState copyWith({
    BudgetStates? state,
    BudgetGoalsListEntity? budgetGoals,
    BudgetGoalsInsightEntity? budgetGoalsInsight,
    FilterDefaultValue? defaultPeriod,
    String? message,
    StackTrace? stackTrace,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? paginationError,
  }) =>
      BudgetState(
        state: state ?? this.state,
        budgetGoals: budgetGoals ?? this.budgetGoals,
        budgetGoalsInsight: budgetGoalsInsight ?? this.budgetGoalsInsight,
        defaultPeriod: defaultPeriod ?? this.defaultPeriod,
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
        budgetGoalsInsight,
        defaultPeriod,
        message,
        stackTrace,
        currentPage,
        hasReachedMax,
        isLoadingMore,
        paginationError,
      ];

  // Helper getters for UI logic
  bool get isInitialLoading =>
      state == BudgetStates.loading && budgetGoals == null;
  bool get hasData =>
      budgetGoals != null && budgetGoals!.budgetGoals.isNotEmpty;
  bool get hasError => state == BudgetStates.error && budgetGoals == null;
  bool get hasPaginationError => paginationError != null;
  bool get canLoadMore => !hasReachedMax && !isLoadingMore && hasData;
}
