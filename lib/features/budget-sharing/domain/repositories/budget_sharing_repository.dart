import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';

abstract class BudgetSharingRepository {
  // invite user
  Future<Either<Failure, BudgetShareResultEntity>> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    double? monthlyLimit,
  });

  // accept invite
  Future<Either<Failure, BudgetShareEntity>> acceptInvite({
    required String budgetId,
  });
}
