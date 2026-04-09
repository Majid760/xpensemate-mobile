import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/revoke_access_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/update_role_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/decline_invite_entity.dart';

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

  // decline invite
  Future<Either<Failure, DeclineInviteEntity>> declineInvite({
    required String budgetId,
  });

  // revoke access
  Future<Either<Failure, RevokeAccessEntity>> revokeAccess({
    required String budgetId,
    required String memberId,
  });

  // update role
  Future<Either<Failure, UpdateRoleEntity>> updateRole({
    required String budgetId,
    required String memberId,
    required String role,
  });
}
