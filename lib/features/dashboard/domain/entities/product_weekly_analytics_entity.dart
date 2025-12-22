import 'package:equatable/equatable.dart';

// ------------------------------------------------------------------
//  Sub-entities for Product Weekly Analytics
// ------------------------------------------------------------------

// ------------------------------------------------------------------
//  Sub-entities for Product Weekly Analytics
// ------------------------------------------------------------------

class AnalyticsSummaryEntity extends Equatable {
  const AnalyticsSummaryEntity({
    required this.totalSpent,
    required this.dailyAverage,
    required this.highestDay,
    required this.lowestDay,
    required this.daysWithExpenses,
  });

  final double totalSpent;
  final double dailyAverage;
  final double highestDay;
  final double lowestDay;
  final int daysWithExpenses;

  @override
  List<Object?> get props => [
        totalSpent,
        dailyAverage,
        highestDay,
        lowestDay,
        daysWithExpenses,
      ];
}

class DailyProductAnalyticsEntity extends Equatable {
  const DailyProductAnalyticsEntity({
    required this.day,
    required this.fullDay,
    required this.date,
    required this.value,
  });

  final String day;
  final String fullDay;
  final String date;
  final double value;

  @override
  List<Object?> get props => [day, fullDay, date, value];
}

class CategoryDataEntity extends Equatable {
  const CategoryDataEntity({
    required this.category,
    required this.data,
    required this.summary,
  });

  final String category;
  final List<DailyProductAnalyticsEntity> data;
  final AnalyticsSummaryEntity summary;

  @override
  List<Object?> get props => [category, data, summary];
}

// ------------------------------------------------------------------
//  Main Product Weekly Analytics Entity
// ------------------------------------------------------------------

class ProductWeeklyAnalyticsEntity extends Equatable {
  const ProductWeeklyAnalyticsEntity({
    required this.categories,
    required this.categoriesData,
    required this.overallSummary,
  });

  final List<String> categories;
  final List<CategoryDataEntity> categoriesData;
  final AnalyticsSummaryEntity overallSummary;

  ProductWeeklyAnalyticsEntity copyWith({
    List<String>? categories,
    List<CategoryDataEntity>? categoriesData,
    AnalyticsSummaryEntity? overallSummary,
  }) =>
      ProductWeeklyAnalyticsEntity(
        categories: categories ?? this.categories,
        categoriesData: categoriesData ?? this.categoriesData,
        overallSummary: overallSummary ?? this.overallSummary,
      );

  @override
  List<Object?> get props => [categories, categoriesData, overallSummary];
}
