import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/budget/data/models/budget_goal_model.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goals_insight_entity.dart';
import 'package:xpensemate/features/budget/domain/usecases/get_budget_goals_by_period_usecase.dart';
import 'package:xpensemate/features/budget/domain/usecases/usecase_export.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(
    this._getBudgetGoalsUseCase,
    this._createBudgetGoalUseCase,
    this._updateBudgetGoalUseCase,
    this._deleteBudgetGoalUseCase,
    this._getBudgetGoalsByPeriodUseCase,
  ) : super(const BudgetState()) {
    // Initialize with insights only, let pagination handle the list
    getBudgetGoalsInsights(period: 'monthly');
  }

  final GetBudgetsGoalsUseCase _getBudgetGoalsUseCase;
  final CreateBudgetGoalUseCase _createBudgetGoalUseCase;
  final UpdateBudgetGoalUseCase _updateBudgetGoalUseCase;
  final DeleteBudgetGoalUseCase _deleteBudgetGoalUseCase;
  final GetBudgetGoalsByPeriodUseCase _getBudgetGoalsByPeriodUseCase;

  static const int _limit = 10;

  // Local cache for budget goals to enable optimistic updates
  final List<BudgetGoalEntity> _allBudgetGoals = [];

  /// Fetches budget goals for a specific page
  /// Returns the data through state emission for the UI to handle
  Future<void> getBudgetGoals({int page = 1}) async {
    try {
      // Only show global loading for first page
      if (page == 1) {
        emit(state.copyWith(state: BudgetStates.loading, message: ''));
      }

      final result = await _getBudgetGoalsUseCase.call(
        GetBudgetGoalsParams(page: page, limit: _limit),
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (data) {
          // Update local cache
          if (page == 1) {
            _allBudgetGoals.clear();
            _allBudgetGoals.addAll(data.budgetGoals);
          } else {
            // For subsequent pages, append new items avoiding duplicates
            for (final newGoal in data.budgetGoals) {
              if (!_allBudgetGoals.any((existing) => existing.id == newGoal.id)) {
                _allBudgetGoals.add(newGoal);
              }
            }
          }

          final hasReachedMax = page >= data.totalPages;
          emit(
            state.copyWith(
              state: BudgetStates.loaded,
              message: '', // Clear any previous messages
              budgetGoals: BudgetGoalsListModel(
                budgetGoals: data.budgetGoals,
                total: data.total,
                page: page,
                totalPages: data.totalPages,
              ),
              hasReachedMax: hasReachedMax,
            ),
          );
        },
      );
    } on Exception catch (e, stack) {
      logE('getBudgetGoals error: $e', stack);
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Failed to load budget goals: $e',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Refreshes the budget goals list and insights
  Future<void> refreshBudgetGoals() async {
    await Future.wait([
      getBudgetGoals(),
      getBudgetGoalsInsights(period: 'monthly'),
    ]);
  }

  /// Recalculates budget insights based on current goals
  Future<BudgetGoalsInsightEntity?> _recalculateBudgetInsights({List<BudgetGoalEntity>? goals}) async {
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

  /// Creates a new budget goal
  Future<void> createBudgetGoal(BudgetGoalEntity goal) async {
    try {
      emit(state.copyWith(state: BudgetStates.loading));
      final result = await _createBudgetGoalUseCase.call(CreateBudgetGoalParams(budgetGoal: goal));
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
          // Add to local cache
          _allBudgetGoals.add(createdGoal);

          final updatedGoals = [
            createdGoal,
            ...?state.budgetGoals?.budgetGoals,
          ];
          final insight = await _recalculateBudgetInsights();
          emit(
            state.copyWith(
              budgetGoals: state.budgetGoals?.copyWith(budgetGoals: updatedGoals),
              state: BudgetStates.loaded,
              budgetGoalsInsight: insight ?? state.budgetGoalsInsight,
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
    // Validate input
    if (goal.id.isEmpty) {
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Invalid budget goal: missing ID',
        ),
      );
      return;
    }

    try {
      // Optimistic update - update local cache immediately
      final originalBudgetGoals = state.budgetGoals;
      final originalAllBudgetGoals = List<BudgetGoalEntity>.from(_allBudgetGoals);

      // Update local cache
      final cacheIndex = _allBudgetGoals.indexWhere((g) => g.id == goal.id);
      if (cacheIndex != -1) {
        _allBudgetGoals[cacheIndex] = goal;
      }

      // Update current state if we have budget goals loaded
      if (state.budgetGoals != null) {
        final updatedGoals = state.budgetGoals!.budgetGoals.map((g) => g.id == goal.id ? goal : g).toList();
        final updatedListModel = state.budgetGoals!.copyWith(budgetGoals: updatedGoals);
        emit(state.copyWith(budgetGoals: updatedListModel));
      }

      emit(state.copyWith(state: BudgetStates.loading));

      final result = await _updateBudgetGoalUseCase.call(
        UpdateBudgetGoalParams(budgetGoal: goal),
      );

      result.fold(
        (failure) {
          // Rollback on failure
          _allBudgetGoals.clear();
          _allBudgetGoals.addAll(originalAllBudgetGoals);
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.message,
              budgetGoals: originalBudgetGoals,
            ),
          );
        },
        (updatedGoal) {
          // Update successful - update the local cache with the returned goal
          final cacheIndex = _allBudgetGoals.indexWhere((g) => g.id == updatedGoal.id);
          if (cacheIndex != -1) {
            _allBudgetGoals[cacheIndex] = updatedGoal;
          }

          // Update current state with the updated goal
          if (state.budgetGoals != null) {
            final updatedGoals =
                state.budgetGoals!.budgetGoals.map((g) => g.id == updatedGoal.id ? updatedGoal : g).toList();
            final updatedListModel = state.budgetGoals!.copyWith(budgetGoals: updatedGoals);
            _recalculateBudgetInsights();
            emit(
              state.copyWith(
                state: BudgetStates.loaded,
                message: 'Budget goal updated successfully',
                budgetGoals: updatedListModel,
              ),
            );
          } else {
            emit(
              state.copyWith(
                state: BudgetStates.loaded,
                message: 'Budget goal updated successfully',
              ),
            );
          }

          // Recalculate insights after updating a goal
          _recalculateBudgetInsights();
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
    if (id.isEmpty) {
      emit(
        state.copyWith(
          state: BudgetStates.error,
          message: 'Invalid budget goal ID',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(state: BudgetStates.loading));

      final result = await _deleteBudgetGoalUseCase.call(
        DeleteBudgetGoalParams(id: id),
      );
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: BudgetStates.error,
              message: failure.toString(),
            ),
          );
        },
        (_) {
          // Remove from local cache
          _allBudgetGoals.removeWhere((goal) => goal.id == id);

          emit(
            state.copyWith(
              state: BudgetStates.loaded,
              budgetGoals: state.budgetGoals?.copyWith(
                budgetGoals: state.budgetGoals!.budgetGoals.where((goal) => goal.id != id).toList(),
              ),
              message: 'Budget goal deleted successfully',
            ),
          );

          // Recalculate insights after deleting a goal
          _recalculateBudgetInsights();
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
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _getBudgetGoalsByPeriodUseCase.call(
        GetBudgetGoalsByPeriodParams(
          period: period,
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
}

extension BudgetCubitX on BuildContext {
  BudgetCubit get budgetCubit => read<BudgetCubit>();
}
