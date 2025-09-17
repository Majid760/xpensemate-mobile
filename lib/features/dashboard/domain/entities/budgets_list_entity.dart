import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/expense/domain/entities/budgets_entity.dart';

class BudgetsListEntity extends Equatable {
  const BudgetsListEntity({
    required this.budgets,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<BudgetEntity> budgets;
  final int total;
  final int page;
  final int totalPages;

  @override
  List<Object?> get props => [
        budgets,
        total,
        page,
        totalPages,
      ];

  BudgetsListEntity copyWith({
    List<BudgetEntity>? budgets,
    int? total,
    int? page,
    int? totalPages,
  }) =>
      BudgetsListEntity(
        budgets: budgets ?? this.budgets,
        total: total ?? this.total,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}
