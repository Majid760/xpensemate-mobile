import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/domain/usecases/get_budget_goals_by_period_usecase.dart';
import 'package:xpensemate/features/budget/domain/usecases/usecase_export.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(
    this._getBudgetGoalsUseCase,
    this._createBudgetGoalUseCase,
    this._updateBudgetGoalUseCase,
    this._deleteBudgetGoalUseCase,
    this._getBudgetGoalsByPeriodUseCase,
  ) : super(const BudgetState()) {
    // Initialize with insights only
    getBudgetGoalsInsights(period: FilterDefaultValue.monthly);
    _pagingController.addListener(_showPaginationError);
  }

  //
  @override
  Future<void> close() async {
    _pagingController.cancel();
    return super.close();
  }

  final GetBudgetsGoalsUseCase _getBudgetGoalsUseCase;
  final CreateBudgetGoalUseCase _createBudgetGoalUseCase;
  final UpdateBudgetGoalUseCase _updateBudgetGoalUseCase;
  final DeleteBudgetGoalUseCase _deleteBudgetGoalUseCase;
  final GetBudgetGoalsByPeriodUseCase _getBudgetGoalsByPeriodUseCase;

  static const int _limit = 10;
  static String _searchTerm = '';

  late final _pagingController = PagingController<int, BudgetGoalEntity>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async =>
        getBudgetGoals(page: pageKey, filterQuery: _searchTerm),
  );
  PagingController<int, BudgetGoalEntity> get pagingController =>
      _pagingController;

  /// Fetches budget goals for a specific page
  /// Returns the data directly for the UI to handle, while also emitting state
  Future<List<BudgetGoalEntity>> getBudgetGoals({
    int page = 1,
    String filterQuery = '',
  }) async {
    try {
      final result = await _getBudgetGoalsUseCase.call(
        GetBudgetGoalsParams(
          page: page,
          limit: _limit,
          filterQuery: filterQuery,
        ),
      );
      return result.fold(
        (failure) => [],
        (data) => data.budgetGoals,
      );
    } on Exception catch (e, stack) {
      logE('getBudgetGoals error: $e', stack);
      return [];
    }
  }

  /// Creates a new budget goal
  Future<void> createBudgetGoal(BudgetGoalEntity goal) async {
    try {
      final result = await _createBudgetGoalUseCase
          .call(CreateBudgetGoalParams(budgetGoal: goal));
      await result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (createdGoal) async {
          pagingController.value = pagingController.value.copyWith(
            pages: [
              [createdGoal],
              ...pagingController.value.pages ?? [],
            ],
            keys: [...pagingController.value.keys ?? [], 1],
          );
          _pagingController.refresh();
          final insight = await _recalculateBudgetInsights(
            goals: state.budgetGoalsInsight?.copyWith(
              goals: [...?state.budgetGoalsInsight?.goals, createdGoal],
            ).goals,
          );
          emit(
            state.copyWith(
              budgetGoalsInsight: insight,
              state: BudgetStates.loaded,
              message: 'Budget goal created successfully',
            ),
          );
        },
      );
    } on Exception catch (e, stack) {
      logE('createBudgetGoal error: $e', stack);
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to create budget goal: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Updates an existing budget goal
  Future<void> updateBudgetGoal(BudgetGoalEntity goal) async {
    try {
      final result = await _updateBudgetGoalUseCase.call(
        UpdateBudgetGoalParams(budgetGoal: goal),
      );
      await result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (updatedGoal) async {
          // Create new pages list with updated item
          var pages = <List<BudgetGoalEntity>>[];
          final newPages = <List<BudgetGoalEntity>>[];
          pages = [...?pagingController.value.pages];

          for (final page in pages) {
            final newPage =
                page.map((item) => item.id == goal.id ? goal : item).toList();
            newPages.add(newPage);
          }
          pagingController.value = pagingController.value.copyWith(
            pages: newPages,
          );
          _pagingController.refresh();
          final insight = await _recalculateBudgetInsights(
            goals: state.budgetGoalsInsight?.goals
                .map((element) => element.id == goal.id ? goal : element)
                .toList(),
          );
          emit(
            state.copyWith(
              budgetGoalsInsight: insight,
              state: BudgetStates.loaded,
              message: 'Budget goal updated successfully',
            ),
          );
        },
      );
    } on Exception catch (e, stack) {
      logE('updateBudgetGoal error: $e', stack);
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to update budget goal: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Deletes a budget goal
  Future<void> deleteBudgetGoal(String id) async {
    try {
      final result = await _deleteBudgetGoalUseCase.call(
        DeleteBudgetGoalParams(id: id),
      );
      await result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (_) async {
          // Update paging controller pages by removing the deleted goal
          var pages = <List<BudgetGoalEntity>>[];
          final newPages = <List<BudgetGoalEntity>>[];
          pages = [...?pagingController.value.pages];

          for (final page in pages) {
            final newPage = page.where((item) => item.id != id).toList();
            newPages.add(newPage);
          }
          pagingController.value = pagingController.value.copyWith(
            pages: newPages,
          );
          _pagingController.refresh();

          // Recalculate insights after deleting a goal
          final insight = await _recalculateBudgetInsights(
            goals: state.budgetGoalsInsight?.goals
                .where((goal) => goal.id != id)
                .toList(),
          );
          emit(
            state.copyWith(
              budgetGoalsInsight: insight,
              state: BudgetStates.loaded,
              message: 'Budget goal deleted successfully',
            ),
          );
        },
      );
    } on Exception catch (e, stack) {
      logE('deleteBudgetGoal error: $e', stack);
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to delete budget goal: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Fetches budget goals insights for analytics/dashboard
  Future<void> getBudgetGoalsInsights({
    required FilterDefaultValue period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _getBudgetGoalsByPeriodUseCase.call(
        GetBudgetGoalsByPeriodParams(
          period: period.name,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      result.fold(
        (failure) {
          logE('Failed to get budget goals insights: $failure');
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (budgetGoals) {
          emit(
            state.copyWith(
              state: BudgetStates.loaded,
              defaultPeriod: period,
              budgetGoalsInsight: budgetGoals,
            ),
          );
        },
      );
    } on Exception catch (e, stack) {
      logE('getBudgetGoalsInsights error: $e', stack);
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to get budget goals insights: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Refreshes the budget goals list and insights
  Future<void> refreshBudgetGoals() async {
    await Future.wait([
      getBudgetGoals(),
      getBudgetGoalsInsights(period: FilterDefaultValue.monthly),
    ]);
  }

  /// Recalculates budget insights based on current goals
  Future<BudgetGoalsInsightEntity?> _recalculateBudgetInsights({
    List<BudgetGoalEntity>? goals,
  }) async {
    try {
      final recalculatedInsight = await compute(
        BudgetGoalsInsightEntity.fromGoals,
        goals ?? state.budgetGoals?.budgetGoals ?? [],
      );
      return recalculatedInsight;
    } on Exception catch (e, stack) {
      logE('Failed to recalculate budget insights: $e', stack);
      return null;
    }
  }

  void updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  void _showPaginationError() {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Something went wrong while fetching budget goals.',
        ),
      );
    }
  }
}

extension BudgetCubitX on BuildContext {
  BudgetCubit get budgetCubit => read<BudgetCubit>();
}
