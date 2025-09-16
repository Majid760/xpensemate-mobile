import 'package:xpensemate/core/utils/app_logger.dart';

import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';

// ------------------------------------------------------------------
//  Sub-models for Product Weekly Analytics
// ------------------------------------------------------------------

class DailyProductAnalyticsModel extends DailyProductAnalyticsEntity {
  const DailyProductAnalyticsModel({
    required super.date,
    required super.total,
  });

  factory DailyProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      return DailyProductAnalyticsModel(
        date: json['date'] as String? ?? '',
        total: (json['value'] as num?)?.toDouble() ??
            0.0, // Changed from 'total' to 'value'
      );
    } catch (e) {
      AppLogger.e("Error parsing DailyProductAnalyticsModel from JSON", e);
      rethrow;
    }
  }

  factory DailyProductAnalyticsModel.fromEntity(
    DailyProductAnalyticsEntity entity,
  ) =>
      DailyProductAnalyticsModel(
        date: entity.date,
        total: entity.total,
      );

  DailyProductAnalyticsEntity toEntity() => DailyProductAnalyticsEntity(
        date: date,
        total: total,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'total': total,
      };
}

class DayProductAnalyticsModel extends DayProductAnalyticsEntity {
  const DayProductAnalyticsModel({
    required super.date,
    required super.total,
  });

  factory DayProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      return DayProductAnalyticsModel(
        date: json['date'] as String? ?? '',
        total: (json['value'] as num?)?.toDouble() ??
            0.0, // Changed from 'total' to 'value'
      );
    } catch (e) {
      AppLogger.e("Error parsing DayProductAnalyticsModel from JSON", e);
      rethrow;
    }
  }

  factory DayProductAnalyticsModel.fromEntity(
    DayProductAnalyticsEntity entity,
  ) =>
      DayProductAnalyticsModel(
        date: entity.date,
        total: entity.total,
      );

  DayProductAnalyticsEntity toEntity() => DayProductAnalyticsEntity(
        date: date,
        total: total,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'total': total,
      };
}

// ------------------------------------------------------------------
//  Main Product Weekly Analytics Model
// ------------------------------------------------------------------

class ProductWeeklyAnalyticsModel extends ProductWeeklyAnalyticsEntity {
  const ProductWeeklyAnalyticsModel({
    required super.days,
    required super.dailyBreakdown,
    required super.weekTotal,
    required super.balanceLeft,
    required super.weeklyBudget,
    required super.dailyAverage,
    required super.highestDay,
    required super.lowestDay,
    super.availableCategories,
    super.currentCategory,
    super.allCategoryData,
  });

  /// Create analytics model for a specific category from the API response
  factory ProductWeeklyAnalyticsModel.fromJsonForCategory(
    Map<String, dynamic> json,
    String category,
  ) {
    try {
      AppLogger.d(
        "Parsing ProductWeeklyAnalyticsModel for category '$category' from JSON",
      );

      // Extract the actual data from the nested structure
      final responseData = json['data'] as Map<String, dynamic>? ?? {};

      // Extract available categories directly from the response data keys
      final availableCategories = responseData.keys.toList();

      // Get data for the specified category directly from responseData
      final categoryData = responseData[category] as List? ?? [];

      AppLogger.d("Found ${categoryData.length} days for category '$category'");

      // Parse days data from the specified category
      final daysList = categoryData.map((e) {
        try {
          return DailyProductAnalyticsModel.fromJson(e as Map<String, dynamic>);
        } on Exception catch (dayError) {
          AppLogger.e("Error parsing day: $e", dayError);
          return const DailyProductAnalyticsModel(date: '', total: 0);
        }
      }).toList();

      // Calculate statistics from the days data
      final values = daysList.map((day) => day.total).toList();
      final weekTotal = values.fold<double>(0, (sum, value) => sum + value);
      final dailyAverage = values.isNotEmpty ? weekTotal / values.length : 0.0;

      // Find highest and lowest days
      var highestDay = const DayProductAnalyticsModel(date: '', total: 0);
      var lowestDay = const DayProductAnalyticsModel(date: '', total: 0);

      if (daysList.isNotEmpty) {
        final nonZeroDays = daysList.where((day) => day.total > 0).toList();
        if (nonZeroDays.isNotEmpty) {
          highestDay = DayProductAnalyticsModel(
            date: nonZeroDays.reduce((a, b) => a.total > b.total ? a : b).date,
            total:
                nonZeroDays.reduce((a, b) => a.total > b.total ? a : b).total,
          );
          lowestDay = DayProductAnalyticsModel(
            date: nonZeroDays.reduce((a, b) => a.total < b.total ? a : b).date,
            total:
                nonZeroDays.reduce((a, b) => a.total < b.total ? a : b).total,
          );
        }
      }

      // Parse all category data
      final allCategoryData = <String, List<DailyProductAnalyticsEntity>>{};
      responseData.forEach((categoryName, categoryData) {
        if (categoryData is List) {
          final categoryDays = categoryData.map((e) {
            try {
              return DailyProductAnalyticsModel.fromJson(
                e as Map<String, dynamic>,
              );
            } on Exception catch (dayError) {
              AppLogger.e(
                "Error parsing day for category $categoryName: $e",
                dayError,
              );
              return const DailyProductAnalyticsModel(date: '', total: 0);
            }
          }).toList();
          allCategoryData[categoryName] = categoryDays;
        }
      });

      return ProductWeeklyAnalyticsModel(
        days: daysList,
        dailyBreakdown: daysList, // Same as days for now
        weekTotal: weekTotal,
        balanceLeft: 0, // Not provided by API, defaulting to 0
        weeklyBudget: 0, // Not provided by API, defaulting to 0
        dailyAverage: dailyAverage,
        highestDay: highestDay,
        lowestDay: lowestDay,
        availableCategories: availableCategories,
        currentCategory: category,
        allCategoryData: allCategoryData,
      );
    } catch (e) {
      AppLogger.e(
        "Error parsing ProductWeeklyAnalyticsModel for category '$category' from JSON: ${json.toString()}",
        e,
      );
      rethrow;
    }
  }

  factory ProductWeeklyAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      AppLogger.d(
        "Parsing ProductWeeklyAnalyticsModel from JSON: $json",
      );

      // Extract the actual data from the nested structure
      final responseData = json['data'] as Map<String, dynamic>? ?? {};
      AppLogger.d("Response data: $responseData");

      // Print debug info about category keys
      AppLogger.d("🔍 RAW Category keys: ${responseData.keys.toList()}");

      // Extract available categories directly from the response data keys
      // The categories are the keys of the responseData object
      final availableCategories = responseData.keys.toList();
      AppLogger.d("Available categories: $availableCategories");

      // Default to first category or 'Food' if no categories available
      final currentCategory =
          availableCategories.isNotEmpty ? availableCategories.first : 'Food';
      AppLogger.d("Current category: $currentCategory");

      // Get data for the current category directly from responseData
      final categoryData = responseData[currentCategory] as List? ?? [];

      AppLogger.d(
        "Category data for '$currentCategory': $categoryData",
      );
      AppLogger.d("Category data length: ${categoryData.length}");

      // Parse days data from the current category
      final daysList = categoryData.map((e) {
        try {
          final dailyModel =
              DailyProductAnalyticsModel.fromJson(e as Map<String, dynamic>);
          AppLogger.d("Parsed day: ${dailyModel.date} -> ${dailyModel.total}");
          return dailyModel;
        } on Exception catch (dayError) {
          AppLogger.e("Error parsing day: $e", dayError);
          return const DailyProductAnalyticsModel(date: '', total: 0);
        }
      }).toList();

      AppLogger.d("Total days parsed: ${daysList.length}");

      // Calculate statistics from the days data
      final values = daysList.map((day) => day.total).toList();
      final weekTotal = values.fold<double>(0, (sum, value) => sum + value);
      final dailyAverage = values.isNotEmpty ? weekTotal / values.length : 0.0;

      AppLogger.d("Week total: $weekTotal, Daily average: $dailyAverage");

      // Find highest and lowest days
      var highestDay = const DayProductAnalyticsModel(date: '', total: 0);
      var lowestDay = const DayProductAnalyticsModel(date: '', total: 0);

      if (daysList.isNotEmpty) {
        final nonZeroDays = daysList.where((day) => day.total > 0).toList();
        if (nonZeroDays.isNotEmpty) {
          highestDay = DayProductAnalyticsModel(
            date: nonZeroDays.reduce((a, b) => a.total > b.total ? a : b).date,
            total:
                nonZeroDays.reduce((a, b) => a.total > b.total ? a : b).total,
          );
          lowestDay = DayProductAnalyticsModel(
            date: nonZeroDays.reduce((a, b) => a.total < b.total ? a : b).date,
            total:
                nonZeroDays.reduce((a, b) => a.total < b.total ? a : b).total,
          );
        }
      }

      // Print debug info about category keys
      AppLogger.d(
        "🔍 Category keys before processing: ${responseData.keys.toList()}",
      );

      // Parse all category data - ENSURE we use the exact same keys!
      final allCategoryData = <String, List<DailyProductAnalyticsEntity>>{};

      for (final categoryName in availableCategories) {
        final categoryRawData = responseData[categoryName];
        AppLogger.d("🔍 Processing category: '$categoryName'");

        if (categoryRawData is List) {
          final categoryDays = categoryRawData.map((e) {
            try {
              return DailyProductAnalyticsModel.fromJson(
                e as Map<String, dynamic>,
              );
            } on Exception catch (dayError) {
              AppLogger.e(
                "Error parsing day for category $categoryName: $e",
                dayError,
              );
              return const DailyProductAnalyticsModel(date: '', total: 0);
            }
          }).toList();

          // Use the exact same string from availableCategories as the key
          allCategoryData[categoryName] = categoryDays;
          AppLogger.d(
            "🔍 Added data for category: '$categoryName' with ${categoryDays.length} days",
          );
        }
      }

      // Print debug info about finalized category data
      AppLogger.d("📊 Final available categories: $availableCategories");
      AppLogger.d(
        "🗃️ Final allCategoryData keys: ${allCategoryData.keys.toList()}",
      );

      // Ensure the keys in allCategoryData match exactly with availableCategories
      for (final category in availableCategories) {
        if (!allCategoryData.containsKey(category)) {
          AppLogger.e(
            "⚠️ Category mismatch: '$category' in availableCategories but not in allCategoryData",
          );
        }
      }

      final result = ProductWeeklyAnalyticsModel(
        days: daysList,
        dailyBreakdown: daysList, // Same as days for now
        weekTotal: weekTotal,
        balanceLeft: 0, // Not provided by API, defaulting to 0
        weeklyBudget: 0, // Not provided by API, defaulting to 0
        dailyAverage: dailyAverage,
        highestDay: highestDay,
        lowestDay: lowestDay,
        availableCategories: availableCategories,
        currentCategory: currentCategory,
        allCategoryData: allCategoryData,
      );

      // Final check of data
      AppLogger.d("📊 Result - currentCategory: '${result.currentCategory}'");
      AppLogger.d(
        "📊 Result - availableCategories: ${result.availableCategories}",
      );
      AppLogger.d(
        "📊 Result - allCategoryData keys: ${result.allCategoryData.keys.toList()}",
      );
      AppLogger.d("📊 Result - days count: ${result.days.length}");
      AppLogger.d(
        "✅ Successfully created ProductWeeklyAnalyticsModel with ${result.days.length} days",
      );
      return result;
    } catch (e) {
      AppLogger.e(
        "Error parsing ProductWeeklyAnalyticsModel from JSON: $json",
        e,
      );
      rethrow;
    }
  }

  factory ProductWeeklyAnalyticsModel.fromEntity(
    ProductWeeklyAnalyticsEntity entity,
  ) =>
      ProductWeeklyAnalyticsModel(
        days: entity.days.map(DailyProductAnalyticsModel.fromEntity).toList(),
        dailyBreakdown: entity.dailyBreakdown
            .map(DailyProductAnalyticsModel.fromEntity)
            .toList(),
        weekTotal: entity.weekTotal,
        balanceLeft: entity.balanceLeft,
        weeklyBudget: entity.weeklyBudget,
        dailyAverage: entity.dailyAverage,
        highestDay: DayProductAnalyticsModel.fromEntity(entity.highestDay),
        lowestDay: DayProductAnalyticsModel.fromEntity(entity.lowestDay),
        availableCategories: entity.availableCategories,
        currentCategory: entity.currentCategory,
        allCategoryData: entity.allCategoryData,
      );

  ProductWeeklyAnalyticsEntity toEntity() => ProductWeeklyAnalyticsEntity(
        days: days,
        dailyBreakdown: dailyBreakdown,
        weekTotal: weekTotal,
        balanceLeft: balanceLeft,
        weeklyBudget: weeklyBudget,
        dailyAverage: dailyAverage,
        highestDay: highestDay,
        lowestDay: lowestDay,
        availableCategories: availableCategories,
        currentCategory: currentCategory,
        allCategoryData: allCategoryData,
      );

  Map<String, dynamic> toJson() => {
        'days': days
            .map((e) => (e as DailyProductAnalyticsModel).toJson())
            .toList(),
        'dailyBreakdown': dailyBreakdown
            .map((e) => (e as DailyProductAnalyticsModel).toJson())
            .toList(),
        'weekTotal': weekTotal,
        'balanceLeft': balanceLeft,
        'weeklyBudget': weeklyBudget,
        'dailyAverage': dailyAverage,
        'highestDay': (highestDay as DayProductAnalyticsModel).toJson(),
        'lowestDay': (lowestDay as DayProductAnalyticsModel).toJson(),
        'availableCategories': availableCategories,
        'currentCategory': currentCategory,
      };
}
