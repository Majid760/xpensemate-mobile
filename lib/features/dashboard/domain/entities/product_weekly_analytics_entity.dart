import 'package:equatable/equatable.dart';

// ------------------------------------------------------------------
//  Sub-entities for Product Weekly Analytics
// ------------------------------------------------------------------

class DailyProductAnalyticsEntity extends Equatable {
  const DailyProductAnalyticsEntity({
    required this.date,
    required this.total,
  });

  final String date;
  final double total;

  @override
  List<Object?> get props => [date, total];
}

class DayProductAnalyticsEntity extends Equatable {
  const DayProductAnalyticsEntity({
    required this.date,
    required this.total,
  });

  final String date;
  final double total;

  @override
  List<Object?> get props => [date, total];
}

// ------------------------------------------------------------------
//  Main Product Weekly Analytics Entity
// ------------------------------------------------------------------

class ProductWeeklyAnalyticsEntity extends Equatable {
  const ProductWeeklyAnalyticsEntity({
    required this.days,
    required this.dailyBreakdown,
    required this.weekTotal,
    required this.balanceLeft,
    required this.weeklyBudget,
    required this.dailyAverage,
    required this.highestDay,
    required this.lowestDay,
    this.availableCategories = const [],
    this.currentCategory = 'Food',
    this.allCategoryData = const {},
  });

  final List<DailyProductAnalyticsEntity> days;
  final List<DailyProductAnalyticsEntity> dailyBreakdown;
  final double weekTotal;
  final double balanceLeft;
  final double weeklyBudget;
  final double dailyAverage;
  final DayProductAnalyticsEntity highestDay;
  final DayProductAnalyticsEntity lowestDay;
  final List<String> availableCategories;
  final String currentCategory;
  final Map<String, List<DailyProductAnalyticsEntity>> allCategoryData;

  ProductWeeklyAnalyticsEntity copyWith({
    List<DailyProductAnalyticsEntity>? days,
    List<DailyProductAnalyticsEntity>? dailyBreakdown,
    double? weekTotal,
    double? balanceLeft,
    double? weeklyBudget,
    double? dailyAverage,
    DayProductAnalyticsEntity? highestDay,
    DayProductAnalyticsEntity? lowestDay,
    List<String>? availableCategories,
    String? currentCategory,
    Map<String, List<DailyProductAnalyticsEntity>>? allCategoryData,
  }) => ProductWeeklyAnalyticsEntity(
      days: days ?? this.days,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
      weekTotal: weekTotal ?? this.weekTotal,
      balanceLeft: balanceLeft ?? this.balanceLeft,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      highestDay: highestDay ?? this.highestDay,
      lowestDay: lowestDay ?? this.lowestDay,
      availableCategories: availableCategories ?? this.availableCategories,
      currentCategory: currentCategory ?? this.currentCategory,
      allCategoryData: allCategoryData ?? this.allCategoryData,
    );

  @override
  List<Object?> get props => [
    days,
    dailyBreakdown,
    weekTotal,
    balanceLeft,
    weeklyBudget,
    dailyAverage,
    highestDay,
    lowestDay,
    availableCategories,
    currentCategory,
    allCategoryData,
  ];
}