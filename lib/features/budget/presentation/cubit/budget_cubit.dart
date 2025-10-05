import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
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
  final GetBudgetsGoalsUseCase _getBudgetGoalsUseCase;
  final CreateBudgetGoalUseCase _createBudgetGoalUseCase;
  final UpdateBudgetGoalUseCase _updateBudgetGoalUseCase;
  final DeleteBudgetGoalUseCase _deleteBudgetGoalUseCase;
  final GetBudgetGoalsStatsUseCase _budgetGoalsStatsUseCase;

  // Pagination state management
  final List<BudgetGoalEntity> _allBudgetGoals = [];
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;
  int _defaultLimit = 10;

  Future<void> getBudgetGoals({
    int page = 1,
    int limit = 10,
    bool refresh = false,
    bool loadMore = false,
  }) async {
    try {
      // Prevent multiple concurrent requests for pagination
      if (_isLoadingMore && loadMore) return;
      if (_hasReachedMax && loadMore) return;

      // Handle refresh - reset pagination state
      if (refresh || page == 1) {
        _resetPaginationState();
        emit(
          state.copyWith(
            state: BudgetStates.loading,
          ),
        );
      } else if (loadMore) {
        // Loading more items
        _isLoadingMore = true;
        emit(
          state.copyWith(
            state: BudgetStates.loadingMore,
            isLoadingMore: true,
          ),
        );
      } else if (state.budgetGoals == null) {
        // Initial load
        emit(state.copyWith(state: BudgetStates.loading));
      }

      _currentPage = page;
      _defaultLimit = limit;

      final result = await _getBudgetGoalsUseCase.call(
        GetBudgetGoalsParams(
          page: page,
          limit: limit,
        ),
      );

      result.fold(
        (failure) =>
            _handleBudgetLoadFailure(failure.toString(), page, loadMore),
        (budgetGoals) => _handleBudgetLoadSuccess(
          budgetGoals,
          page,
          refresh || page == 1,
        ),
      );
    } on Exception catch (e, stackTrace) {
      _handleBudgetLoadFailure(
        'Unexpected error: $e',
        page,
        loadMore,
        stackTrace,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Handle successful budget loading with pagination logic
  void _handleBudgetLoadSuccess(
    BudgetGoalsListEntity budgetGoalsList,
    int page,
    bool isFirstPageOrRefresh,
  ) {
    final newBudgetGoals = budgetGoalsList.budgetGoals;

    if (isFirstPageOrRefresh) {
      // First page or refresh - replace all budget goals
      _allBudgetGoals.clear();
      _allBudgetGoals.addAll(newBudgetGoals);
    } else {
      // Subsequent pages - append new budget goals, avoiding duplicates
      final uniqueNewBudgetGoals = newBudgetGoals.where(
        (newBudgetGoal) =>
            !_allBudgetGoals.any((existing) => existing.id == newBudgetGoal.id),
      );
      _allBudgetGoals.addAll(uniqueNewBudgetGoals);
    }

    // Determine if we've reached the maximum
    _hasReachedMax = _currentPage >= budgetGoalsList.totalPages ||
        newBudgetGoals.isEmpty ||
        newBudgetGoals.length < _defaultLimit;

    // Create updated budget goals list entity with all loaded budget goals
    final updatedBudgetGoalsList = BudgetGoalsListEntity(
      budgetGoals: List.from(_allBudgetGoals),
      total: budgetGoalsList.total,
      page: _currentPage,
      totalPages: budgetGoalsList.totalPages,
    );

    emit(
      state.copyWith(
        state: BudgetStates.loaded,
        budgetGoals: updatedBudgetGoalsList,
        currentPage: _currentPage,
        hasReachedMax: _hasReachedMax,
        isLoadingMore: false,
      ),
    );
  }

  /// Handle budget loading failure with appropriate error states
  void _handleBudgetLoadFailure(
    String errorMessage,
    int page,
    bool isLoadMore, [
    StackTrace? stackTrace,
  ]) {
    if (page == 1 || !isLoadMore) {
      // First page error - show main error state
      emit(
        state.copyWith(
          state: BudgetStates.error,
          errorMessage: errorMessage,
          stackTrace: stackTrace,
          isLoadingMore: false,
        ),
      );
    } else {
      // Pagination error - keep existing data, show pagination error
      emit(
        state.copyWith(
          state: BudgetStates.loaded,
          paginationError: errorMessage,
          isLoadingMore: false,
        ),
      );
    }
  }

  /// Load next page for infinite scroll
  Future<void> loadNextPage() async {
    if (_hasReachedMax || _isLoadingMore) return;

    await getBudgetGoals(
      page: _currentPage + 1,
      limit: _defaultLimit,
      loadMore: true,
    );
  }

  /// Refresh budget goals (reload from first page)
  Future<void> refreshBudgetGoals({int limit = 10}) async {
    await getBudgetGoals(
      limit: limit,
      refresh: true,
    );
  }

  /// Check if should load more items (for infinite scroll trigger)
  bool shouldLoadMore(int currentIndex, {int threshold = 5}) {
    if (_hasReachedMax || _isLoadingMore) return false;

    final totalLoaded = _allBudgetGoals.length;
    return currentIndex >= totalLoaded - threshold && totalLoaded > 0;
  }

  /// Trigger load more if conditions are met
  void checkAndLoadMore(int currentIndex, {int threshold = 5}) {
    if (shouldLoadMore(currentIndex, threshold: threshold)) {
      loadNextPage();
    }
  }

  /// Reset pagination state
  void _resetPaginationState() {
    _allBudgetGoals.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
  }

  /// Retry last failed pagination request
  void retryPaginationRequest() {
    if (state.paginationError != null) {
      loadNextPage();
    } else if (state.state == BudgetStates.error) {
      refreshBudgetGoals();
    }
  }

  // Getters for pagination state
  bool get hasReachedMax => _hasReachedMax;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get totalItemsLoaded => _allBudgetGoals.length;
  List<BudgetGoalEntity> get allLoadedBudgetGoals =>
      List.unmodifiable(_allBudgetGoals);
}
