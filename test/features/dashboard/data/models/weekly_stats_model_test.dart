import 'package:flutter_test/flutter_test.dart';
import 'package:xpensemate/features/dashboard/data/models/weekly_stats_model.dart';

void main() {
  group('WeeklyStatsModel', () {
    test('should handle null and missing fields gracefully', () {
      // Test with minimal/null data
      final json = {
        'days': null,
        'dailyBreakdown': [],
        'weekTotal': null,
        'balanceLeft': 50.0,
        'weeklyBudget': null,
        'dailyAverage': 10.5,
        'highestDay': null,
        'lowestDay': {
          'date': null,
          'total': null,
        },
      };

      expect(() => WeeklyStatsModel.fromJson(json), returnsNormally);

      final model = WeeklyStatsModel.fromJson(json);
      expect(model.days, isEmpty);
      expect(model.dailyBreakdown, isEmpty);
      expect(model.weekTotal, equals(0.0));
      expect(model.balanceLeft, equals(50.0));
      expect(model.weeklyBudget, equals(0.0));
      expect(model.dailyAverage, equals(10.5));
      expect(model.highestDay.date, equals(''));
      expect(model.highestDay.total, equals(0.0));
      expect(model.lowestDay.date, equals(''));
      expect(model.lowestDay.total, equals(0.0));
    });

    test('should parse valid complete JSON correctly', () {
      final json = {
        'days': [
          {'date': '2024-01-01', 'total': 25.50},
          {'date': '2024-01-02', 'total': 30.75},
        ],
        'dailyBreakdown': [
          {'date': '2024-01-01', 'total': 25.50},
        ],
        'weekTotal': 100.0,
        'balanceLeft': 200.0,
        'weeklyBudget': 300.0,
        'dailyAverage': 14.3,
        'highestDay': {'date': '2024-01-02', 'total': 30.75},
        'lowestDay': {'date': '2024-01-01', 'total': 25.50},
      };

      final model = WeeklyStatsModel.fromJson(json);

      expect(model.days.length, equals(2));
      expect(model.days.first.date, equals('2024-01-01'));
      expect(model.days.first.total, equals(25.50));
      expect(model.weekTotal, equals(100.0));
      expect(model.balanceLeft, equals(200.0));
      expect(model.weeklyBudget, equals(300.0));
      expect(model.dailyAverage, equals(14.3));
      expect(model.highestDay.date, equals('2024-01-02'));
      expect(model.highestDay.total, equals(30.75));
    });
  });

  group('DailyStatsModel', () {
    test('should handle null values gracefully', () {
      final json = {
        'date': null,
        'total': null,
      };

      expect(() => DailyStatsModel.fromJson(json), returnsNormally);

      final model = DailyStatsModel.fromJson(json);
      expect(model.date, equals(''));
      expect(model.total, equals(0.0));
    });
  });

  group('DayStatsModel', () {
    test('should handle null values gracefully', () {
      final json = {
        'date': null,
        'total': null,
      };

      expect(() => DayStatsModel.fromJson(json), returnsNormally);

      final model = DayStatsModel.fromJson(json);
      expect(model.date, equals(''));
      expect(model.total, equals(0.0));
    });
  });
}
