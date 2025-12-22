import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';

// ------------------------------------------------------------------
//  Sub-models for Product Weekly Analytics
// ------------------------------------------------------------------

class AnalyticsSummaryModel extends AnalyticsSummaryEntity {
  const AnalyticsSummaryModel({
    required super.totalSpent,
    required super.dailyAverage,
    required super.highestDay,
    required super.lowestDay,
    required super.daysWithExpenses,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) =>
      AnalyticsSummaryModel(
        totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
        dailyAverage: (json['dailyAverage'] as num?)?.toDouble() ?? 0.0,
        highestDay: (json['highestDay'] as num?)?.toDouble() ?? 0.0,
        lowestDay: (json['lowestDay'] as num?)?.toDouble() ?? 0.0,
        daysWithExpenses: (json['daysWithExpenses'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalSpent': totalSpent,
        'dailyAverage': dailyAverage,
        'highestDay': highestDay,
        'lowestDay': lowestDay,
        'daysWithExpenses': daysWithExpenses,
      };
}

class DailyProductAnalyticsModel extends DailyProductAnalyticsEntity {
  const DailyProductAnalyticsModel({
    required super.day,
    required super.fullDay,
    required super.date,
    required super.value,
  });

  factory DailyProductAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      DailyProductAnalyticsModel(
        day: json['day'] as String? ?? '',
        fullDay: json['fullDay'] as String? ?? '',
        date: json['date'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'fullDay': fullDay,
        'date': date,
        'value': value,
      };
}

class CategoryDataModel extends CategoryDataEntity {
  const CategoryDataModel({
    required super.category,
    required super.data,
    required super.summary,
  });

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) =>
      CategoryDataModel(
        category: json['category'] as String? ?? '',
        data: (json['data'] as List<dynamic>?)
                ?.map(
                  (e) => DailyProductAnalyticsModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
        summary: AnalyticsSummaryModel.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'data': data
            .map((e) => (e as DailyProductAnalyticsModel).toJson())
            .toList(),
        'summary': (summary as AnalyticsSummaryModel).toJson(),
      };
}

// ------------------------------------------------------------------
//  Main Product Weekly Analytics Model
// ------------------------------------------------------------------

class ProductWeeklyAnalyticsModel extends ProductWeeklyAnalyticsEntity {
  const ProductWeeklyAnalyticsModel({
    required super.categories,
    required super.categoriesData,
    required super.overallSummary,
  });

  factory ProductWeeklyAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>? ?? json;

      final reslt = ProductWeeklyAnalyticsModel(
        categories: (data['categories'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        categoriesData: (data['categoriesData'] as List<dynamic>?)
                ?.map(
                  (e) => CategoryDataModel.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        overallSummary: AnalyticsSummaryModel.fromJson(
          data['overallSummary'] as Map<String, dynamic>? ?? {},
        ),
      );

      return reslt;
    } catch (e) {
      AppLogger.e("Error parsing ProductWeeklyAnalyticsModel from JSON", e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'categories': categories,
          'categoriesData': categoriesData
              .map((e) => (e as CategoryDataModel).toJson())
              .toList(),
          'overallSummary': (overallSummary as AnalyticsSummaryModel).toJson(),
        },
      };
}
