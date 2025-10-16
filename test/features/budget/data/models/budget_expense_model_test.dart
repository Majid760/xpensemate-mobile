import 'package:flutter_test/flutter_test.dart';
import 'package:xpensemate/features/budget/data/models/budget_expense_model.dart';

void main() {
  group('BudgetExpensesListModel', () {
    test('should correctly parse API response with wrapped data format', () {
      // Given
      final json = {
        "data": {
          "expenses": [
            {
              "recurring": {
                "is_recurring": false,
                "frequency": "monthly"
              },
              "_id": "68ce93dd65f846c779e41b8b",
              "user_id": "6812a87e1455bdd4742d3c9b",
              "name": "ksdfjsd",
              "amount": 123,
              "budget_goal_id": "68c1706cf9f508c89823a113",
              "date": "2025-09-20T00:00:00.000Z",
              "time": "16:45",
              "location": "",
              "category_id": "684eecae498dae20b2b32ccf",
              "category": "FOOD",
              "detail": "",
              "payment_method": "credit_card",
              "attachments": [],
              "is_deleted": false,
              "created_at": "2025-09-20T11:45:33.252Z",
              "updated_at": "2025-09-20T11:45:33.252Z",
              "__v": 0
            }
          ]
        }
      };

      // When
      final result = BudgetExpensesListModel.fromJson(json);

      // Then
      expect(result.expenses, isNotEmpty);
      expect(result.expenses.length, 1);
      expect(result.total, 1);
      expect(result.page, 1);
      expect(result.totalPages, 1);
      
      final expense = result.expenses[0];
      expect(expense.id, '68ce93dd65f846c779e41b8b');
      expect(expense.name, 'ksdfjsd');
      expect(expense.amount, 123.0);
    });

    test('should correctly parse API response with direct data format', () {
      // Given
      final json = {
        "expenses": [
          {
            "recurring": {
              "is_recurring": false,
              "frequency": "monthly"
            },
            "_id": "68ce93dd65f846c779e41b8b",
            "user_id": "6812a87e1455bdd4742d3c9b",
            "name": "ksdfjsd",
            "amount": 123,
            "budget_goal_id": "68c1706cf9f508c89823a113",
            "date": "2025-09-20T00:00:00.000Z",
            "time": "16:45",
            "location": "",
            "category_id": "684eecae498dae20b2b32ccf",
            "category": "FOOD",
            "detail": "",
            "payment_method": "credit_card",
            "attachments": [],
            "is_deleted": false,
            "created_at": "2025-09-20T11:45:33.252Z",
            "updated_at": "2025-09-20T11:45:33.252Z",
            "__v": 0
          }
        ],
        "total": 1,
        "page": 1,
        "totalPages": 1
      };

      // When
      final result = BudgetExpensesListModel.fromJson(json);

      // Then
      expect(result.expenses, isNotEmpty);
      expect(result.expenses.length, 1);
      expect(result.total, 1);
      expect(result.page, 1);
      expect(result.totalPages, 1);
      
      final expense = result.expenses[0];
      expect(expense.id, '68ce93dd65f846c779e41b8b');
      expect(expense.name, 'ksdfjsd');
      expect(expense.amount, 123.0);
    });
  });
}