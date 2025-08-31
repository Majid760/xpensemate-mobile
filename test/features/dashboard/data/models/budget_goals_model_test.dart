import 'package:flutter_test/flutter_test.dart';
import 'package:xpensemate/features/dashboard/data/models/budget_goals_model.dart';

void main() {
  group('BudgetGoalsModel', () {
    test('should handle null and missing fields gracefully', () {
      // Test with minimal/null data
      final json = {
        'goals': null,
        'pagination': null,
        'stats': null,
        'duration': null,
        'dateRange': null,
      };

      expect(() => BudgetGoalsModel.fromJson(json), returnsNormally);
      
      final model = BudgetGoalsModel.fromJson(json);
      expect(model.goals, isEmpty);
      expect(model.pagination.currentPage, equals(1));
      expect(model.pagination.totalPages, equals(1));
      expect(model.pagination.totalGoals, equals(0));
      expect(model.stats.totalGoals, equals(0));
      expect(model.duration, equals(''));
    });

    test('should parse valid complete JSON correctly', () {
      final json = {
        'goals': [
          {
            '_id': 'goal1',
            'name': 'Test Goal',
            'category': 'Food',
            'setBudget': 500.0,
            'currentSpending': 250.0,
            'priority': 'high',
            'status': 'active',
            'date': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
          }
        ],
        'pagination': {
          'currentPage': 1,
          'totalPages': 5,
          'totalGoals': 25,
        },
        'stats': {
          'totalGoals': 25,
          'activeGoals': 20,
          'achievedGoals': 5,
          'totalBudgeted': 5000.0,
          'totalAchievedBudget': 1000.0,
        },
        'duration': 'monthly',
        'dateRange': {
          'startDate': '2024-01-01T00:00:00.000Z',
          'endDate': '2024-01-31T23:59:59.999Z',
        },
      };

      final model = BudgetGoalsModel.fromJson(json);
      
      expect(model.goals.length, equals(1));
      expect(model.goals.first.name, equals('Test Goal'));
      expect(model.goals.first.setBudget, equals(500.0));
      expect(model.pagination.totalGoals, equals(25));
      expect(model.stats.activeGoals, equals(20));
      expect(model.duration, equals('monthly'));
    });
  });

  group('BudgetGoalModel', () {
    test('should handle null values gracefully', () {
      final json = {
        '_id': null,
        'name': null,
        'category': null,
        'setBudget': null,
        'currentSpending': null,
        'priority': null,
        'status': null,
        'date': null,
        'created_at': null,
      };

      expect(() => BudgetGoalModel.fromJson(json), returnsNormally);
      
      final model = BudgetGoalModel.fromJson(json);
      expect(model.id, equals(''));
      expect(model.name, equals(''));
      expect(model.category, equals(''));
      expect(model.setBudget, equals(0.0));
      expect(model.currentSpending, equals(0.0));
      expect(model.priority, equals(''));
      expect(model.status, equals(''));
    });
  });
}