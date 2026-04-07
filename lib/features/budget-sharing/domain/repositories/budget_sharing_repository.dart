import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';

abstract class BudgetSharingRepository {
  Future<Either<Failure, BudgetShareResultEntity>> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    double? monthlyLimit,
  });
}
