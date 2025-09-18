part of 'dashboard_cubit.dart';

enum DashboardStates { initial, loading, loaded, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.state = DashboardStates.initial,
    this.weeklyStats,
    this.budgetGoals,
    this.productAnalytics,
    this.errorMessage,
    this.stackTrace,
  });

  final DashboardStates state;
  final WeeklyStatsEntity? weeklyStats;
  final BudgetGoalsEntity? budgetGoals;
  final ProductWeeklyAnalyticsEntity? productAnalytics;
  final String? errorMessage;
  final StackTrace? stackTrace;

  DashboardState copyWith({
    DashboardStates? state,
    WeeklyStatsEntity? weeklyStats,
    BudgetGoalsEntity? budgetGoals,
    ProductWeeklyAnalyticsEntity? productAnalytics,
    String? errorMessage,
    StackTrace? stackTrace,
  }) =>
      DashboardState(
        state: state ?? this.state,
        weeklyStats: weeklyStats ?? this.weeklyStats,
        budgetGoals: budgetGoals ?? this.budgetGoals,
        productAnalytics: productAnalytics ?? this.productAnalytics,
        errorMessage: errorMessage ?? this.errorMessage,
        stackTrace: stackTrace ?? this.stackTrace,
      );

  @override
  List<Object?> get props => [
        state,
        weeklyStats,
        budgetGoals,
        productAnalytics,
        errorMessage,
        stackTrace,
      ];
}
