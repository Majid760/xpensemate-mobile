import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget/data/models/budget_goal_model.dart';
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

  final List<BudgetGoalEntity> _cache = [];
  int _page = 1;
  int _limit = 10;
  bool _hasMore = true;
  bool _loading = false;

  Future<void> getBudgetGoals({
    int page = 1,
    int limit = 10,
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (_loading && loadMore || !_hasMore && loadMore) return;

    try {
      final isInitial = refresh || page == 1;

      if (isInitial) {
        _resetState();
        emit(state.copyWith(state: BudgetStates.loading));
      } else if (loadMore) {
        _loading = true;
        emit(
          state.copyWith(
            state: BudgetStates.loadingMore,
            isLoadingMore: true,
          ),
        );
      } else if (state.budgetGoals == null) {
        emit(state.copyWith(state: BudgetStates.loading));
      }

      _page = page;
      _limit = limit;

      final result = await _getBudgetGoalsUseCase.call(
        GetBudgetGoalsParams(page: page, limit: limit),
      );

      result.fold(
        (failure) => _emitError(failure.toString(), isInitial),
        (data) => _emitSuccess(data, isInitial),
      );
    } on Exception catch (e, stack) {
      _emitError('Unexpected error: $e', refresh || page == 1, stack);
    } finally {
      _loading = false;
    }
  }

  void _emitSuccess(BudgetGoalsListEntity data, bool isInitial) {
    if (isInitial) {
      _cache
        ..clear()
        ..addAll(data.budgetGoals);
    } else {
      _cache.addAll(
        data.budgetGoals.where((n) => !_cache.any((e) => e.id == n.id)),
      );
    }

    _hasMore = _page < data.totalPages &&
        data.budgetGoals.isNotEmpty &&
        data.budgetGoals.length >= _limit;

    emit(
      state.copyWith(
        state: BudgetStates.loaded,
        message: '',
        budgetGoals: BudgetGoalsListModel(
          budgetGoals: List.from(_cache),
          total: data.total,
          page: _page,
          totalPages: data.totalPages,
        ),
        currentPage: _page,
        hasReachedMax: !_hasMore,
        isLoadingMore: false,
      ),
    );
  }

  void _emitError(String error, bool isInitial, [StackTrace? stack]) {
    emit(
      isInitial
          ? state.copyWith(
              state: BudgetStates.error,
              message: error,
              stackTrace: stack,
              isLoadingMore: false,
            )
          : state.copyWith(
              state: BudgetStates.loaded,
              paginationError: error,
              isLoadingMore: false,
            ),
    );
  }

  void _resetState() {
    _cache.clear();
    _page = 1;
    _hasMore = true;
    _loading = false;
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _loading) return;
    await getBudgetGoals(page: _page + 1, limit: _limit, loadMore: true);
  }

  Future<void> refreshBudgetGoals({int limit = 10}) async {
    await getBudgetGoals(limit: limit, refresh: true);
  }

  bool shouldLoadMore(int index, {int threshold = 5}) =>
      _hasMore && !_loading && index >= _cache.length - threshold && _cache.isNotEmpty;

  void checkAndLoadMore(int index, {int threshold = 5}) {
    if (shouldLoadMore(index, threshold: threshold)) loadNextPage();
  }

  void retryPaginationRequest() {
    if (state.paginationError != null) {
      loadNextPage();
    } else if (state.state == BudgetStates.error) {
      refreshBudgetGoals();
    }
  }

  bool get hasReachedMax => !_hasMore;
  bool get isLoadingMore => _loading;
  int get currentPage => _page;
  int get totalItemsLoaded => _cache.length;
  List<BudgetGoalEntity> get allLoadedBudgetGoals => List.unmodifiable(_cache);

// create budget goal
  Future<void> createBudgetGoal(BudgetGoalEntity goal) async {
    try {
      emit(state.copyWith(state: BudgetStates.loading));

      final result = await _createBudgetGoalUseCase
          .call(CreateBudgetGoalParams(budgetGoal: goal));

      result.fold(
        (failure) => emit(
          state.copyWith(
            state: BudgetStates.error,
            message: failure.toString(),
          ),
        ),
        (createdGoal) {
          _cache.insert(0, createdGoal);
          _emitUpdatedState('Budget goal created successfully');
        },
      );
    } on Exception catch (e, stack) {
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to create: $e',
          stackTrace: stack,
        ),
      );
    }
  }

// Update Budget Goal
  Future<void> updateBudgetGoal(BudgetGoalEntity goal) async {
    final index = _cache.indexWhere((e) => e.id == goal.id);
    if (index == -1) {
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Budget goal not found',
        ),
      );
      return;
    }
    final previous = _cache[index];
    try {
      _cache[index] = goal;
      _emitUpdatedState('');
      final result = await _updateBudgetGoalUseCase
          .call(UpdateBudgetGoalParams(budgetGoal: goal));
      result.fold(
        (failure) {
          _cache[index] = previous;
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (updated) {
          _cache[index] = updated;
          _emitUpdatedState('Budget goal updated successfully');
        },
      );
    } on Exception catch (e, stack) {
      _cache[index] = previous;
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to update: $e',
          stackTrace: stack,
        ),
      );
    }
  }

// delete budget goal
  Future<void> deleteBudgetGoal(String id) async {
    final index = _cache.indexWhere((e) => e.id == id);
    if (index == -1) {
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Budget goal not found',
        ),
      );
      return;
    }
    final removed = _cache.removeAt(index);
    _emitUpdatedState('');
    try {
      final result = await _deleteBudgetGoalUseCase.call(
        DeleteBudgetGoalParams(id: id),
      );
      result.fold(
        (failure) {
          _cache.insert(index, removed);
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (_) => _emitUpdatedState('Budget goal deleted successfully'),
      );
    } on Exception catch (e, stack) {
      _cache.insert(index, removed);
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to delete: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  void _emitUpdatedState([String? message]) {
    final current = state.budgetGoals;
    emit(
      state.copyWith(
        state: BudgetStates.loaded,
        budgetGoals: current != null
            ? BudgetGoalsListModel(
                budgetGoals: List.from(_cache),
                total: _cache.length,
                page: current.page,
                totalPages: current.totalPages,
              )
            : null,
        message: message,
      ),
    );
  }
}

extension ExpenseCubitX on BuildContext {
  BudgetCubit get budgetCubit => read<BudgetCubit>();
}
