import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/service/crashlytics_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_specific_expense_entity.dart';
import 'package:xpensemate/features/budget/domain/usecases/get_budget_specific_expenses_usecase.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_state.dart';

class BudgetExpensesCubit extends Cubit<BudgetExpensesState> {
  BudgetExpensesCubit(
    this._getBudgetSpecificExpensesUseCase,
  ) : super(const BudgetExpensesState()) {
    _crashlytics = sl.crashlytics;
    unawaited(_crashlytics.log('Initializing BudgetExpensesCubit...'));
  }

  final GetBudgetSpecificExpensesUseCase _getBudgetSpecificExpensesUseCase;
  late final CrashlyticsService _crashlytics;

  // Filter parameters
  String _searchQuery = '';
  String _paymentMethodFilter = 'all';

  // get budget specific expenses
  Future<void> getBudgetSpecificExpenses(
    String budgetId, {
    String? searchQuery,
    String? paymentMethod,
  }) async {
    unawaited(_crashlytics
        .log('Fetching budget specific expenses for: $budgetId...'));
    // Update filter parameters
    _searchQuery = searchQuery ?? _searchQuery;
    _paymentMethodFilter = paymentMethod ?? _paymentMethodFilter;

    if (state.budgetGoals == null) {
      emit(state.copyWith(state: BudgetExpensesStates.loading));
    }
    try {
      final result = await _getBudgetSpecificExpensesUseCase
          .call(GetBudgetSpecificExpensesUseCaseParams(budgetId: budgetId));
      result.fold(
        (failure) {
          unawaited(_crashlytics
              .log('Fetch budget expenses failed: ${failure.toString()}'));
          emit(
            state.copyWith(
              state: BudgetExpensesStates.error,
              message: failure.toString(),
            ),
          );
        },
        (expenses) {
          unawaited(_crashlytics.log(
              'Fetch budget expenses success (${expenses.expenses.length} items)'));
          // Store original expenses
          final originalExpensesList = expenses;

          // Apply filters to expenses
          final filteredExpenses = _applyFilters(expenses.expenses);
          final filteredExpensesList =
              expenses.copyWith(expenses: filteredExpenses);

          emit(
            state.copyWith(
              state: BudgetExpensesStates.loaded,
              budgetGoals: filteredExpensesList,
              originalBudgetGoals: originalExpensesList,
            ),
          );
        },
      );
    } on Exception catch (e, s) {
      unawaited(_crashlytics.recordError(e, s,
          reason: 'getBudgetSpecificExpenses failed'));
      emit(
        state.copyWith(
          state: BudgetExpensesStates.error,
          message: e.toString(),
        ),
      );
    }
  }

  // Apply search and filter logic
  List<BudgetSpecificExpensesEntity> _applyFilters(
    List<BudgetSpecificExpensesEntity> expenses,
  ) {
    var filtered = expenses;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (expense) =>
                expense.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                expense.detail
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply payment method filter
    if (_paymentMethodFilter != 'all') {
      // Changed from 'All' to 'all'
      filtered = filtered
          .where((expense) => expense.paymentMethod == _paymentMethodFilter)
          .toList();
    }

    return filtered;
  }

  // Update search query
  void updateSearchQuery(String query) {
    // In a real implementation, you would call getBudgetSpecificExpenses with the new query
    // For now, we'll just update the state and re-apply filters
    _searchQuery = query;
    if (state.originalBudgetGoals != null) {
      final filteredExpenses =
          _applyFilters(state.originalBudgetGoals!.expenses);
      final filteredExpensesList =
          state.originalBudgetGoals!.copyWith(expenses: filteredExpenses);
      emit(state.copyWith(budgetGoals: filteredExpensesList));
    }
  }

  // Update payment method filter
  void updatePaymentMethodFilter(String method) {
    _paymentMethodFilter = method;
    if (state.originalBudgetGoals != null) {
      final filteredExpenses =
          _applyFilters(state.originalBudgetGoals!.expenses);
      final filteredExpensesList =
          state.originalBudgetGoals!.copyWith(expenses: filteredExpenses);
      emit(state.copyWith(budgetGoals: filteredExpensesList));
    }
  }

  // get the budget goals insights
}

extension BudgetExpensesCubitX on BuildContext {
  BudgetExpensesCubit get budgetExpensesCubit => read<BudgetExpensesCubit>();
}
