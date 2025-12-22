import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xpensemate/features/dashboard/data/models/product_weekly_analytics_model.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';

void main() {
  const tProductWeeklyAnalyticsModel = ProductWeeklyAnalyticsModel(
    categories: ['Grocery', 'Entertainment'],
    categoriesData: [
      CategoryDataModel(
        category: 'Grocery',
        data: [
          DailyProductAnalyticsModel(
            day: 'Mon',
            fullDay: 'Monday',
            date: '2023-10-30',
            value: 150.0,
          ),
          DailyProductAnalyticsModel(
            day: 'Tue',
            fullDay: 'Tuesday',
            date: '2023-10-31',
            value: 50.0,
          ),
        ],
        summary: AnalyticsSummaryModel(
          totalSpent: 200.0,
          dailyAverage: 100.0,
          highestDay: 150.0,
          lowestDay: 50.0,
          daysWithExpenses: 2,
        ),
      ),
    ],
    overallSummary: AnalyticsSummaryModel(
      totalSpent: 200.0,
      dailyAverage: 100.0,
      highestDay: 150.0,
      lowestDay: 50.0,
      daysWithExpenses: 2,
    ),
  );

  group('ProductWeeklyAnalyticsModel', () {
    test('should be a subclass of ProductWeeklyAnalyticsEntity', () async {
      expect(tProductWeeklyAnalyticsModel, isA<ProductWeeklyAnalyticsEntity>());
    });

    test('should return a valid model from JSON', () async {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('product_weekly_analytics.json'))
              as Map<String, dynamic>;
      final result = ProductWeeklyAnalyticsModel.fromJson(jsonMap);
      expect(result, equals(tProductWeeklyAnalyticsModel));
    });
  });
}

String fixture(String name) {
  // Minimal internal fixture since we don't have file access to test fixtures easily in this env setup logic
  // Simulating the JSON content directly for this test
  return '''
{
  "status": true,
  "message": "Stats retrieved successfully",
  "data": {
    "categories": ["Grocery", "Entertainment"],
    "categoriesData": [
      {
        "category": "Grocery",
        "data": [
          {"day": "Mon", "fullDay": "Monday", "date": "2023-10-30", "value": 150.0},
          {"day": "Tue", "fullDay": "Tuesday", "date": "2023-10-31", "value": 50.0}
        ],
        "summary": {
          "totalSpent": 200.0,
          "dailyAverage": 100.0,
          "highestDay": 150.0,
          "lowestDay": 50.0,
          "daysWithExpenses": 2
        }
      }
    ],
    "overallSummary": {
      "totalSpent": 200.0,
      "dailyAverage": 100.0,
      "highestDay": 150.0,
      "lowestDay": 50.0,
      "daysWithExpenses": 2
    }
  }
}
''';
}
