import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/budget-sharing/data/models/budget_share_model.dart';
import 'package:xpensemate/features/budget-sharing/data/models/revoke_access_model.dart';
import 'package:xpensemate/features/budget-sharing/data/models/update_role_model.dart';
import 'package:xpensemate/features/budget-sharing/data/models/decline_invite_model.dart';

abstract class BudgetSharingRemoteDataSource {

  // Invite flow and Access
  Future<Either<Failure, BudgetShareResultModel>> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    double? monthlyLimit,
  });

  Future<Either<Failure, BudgetShareModel>> acceptInvite({
    required String budgetId,
  });

  Future<Either<Failure, DeclineInviteModel>> declineInvite({
    required String budgetId,
  });

  Future<Either<Failure, RevokeAccessModel>> revokeAccess({
    required String budgetId,
    required String memberId,
  });

  Future<Either<Failure, UpdateRoleModel>> updateRole({
    required String budgetId,
    required String memberId,
    required String role,
  });

  
}

class BudgetSharingRemoteDataSourceImpl implements BudgetSharingRemoteDataSource {
  BudgetSharingRemoteDataSourceImpl(this._networkClient);

  final NetworkClient _networkClient;

  @override
  Future<Either<Failure, BudgetShareResultModel>> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    double? monthlyLimit,
  }) async {
    final path = NetworkConfigs.shareBudget.replaceAll(':budgetId', budgetId);
    return _networkClient.post(
      path,
      data: {
        'inviteeId': inviteeId,
        'role': role,
        if (monthlyLimit != null) 'monthlyLimit': monthlyLimit,
      },
      fromJson: BudgetShareResultModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, BudgetShareModel>> acceptInvite({
    required String budgetId,
  }) async {
    final path = NetworkConfigs.acceptBudgetShare.replaceAll(':budgetId', budgetId);
    return _networkClient.post(
      path,
      fromJson: (json) => BudgetShareModel.fromJson(json['share'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  Future<Either<Failure, DeclineInviteModel>> declineInvite({
    required String budgetId,
  }) async {
    final path = NetworkConfigs.declineBudgetShare.replaceAll(':budgetId', budgetId);
    return _networkClient.post(
      path,
      fromJson: (json) => DeclineInviteModel.fromJson(json['share'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  Future<Either<Failure, RevokeAccessModel>> revokeAccess({
    required String budgetId,
    required String memberId,
  }) async {
    final path = NetworkConfigs.revokeBudgetShareAccess
        .replaceAll(':budgetId', budgetId)
        .replaceAll(':memberId', memberId);
    return _networkClient.delete(
      path,
      fromJson: RevokeAccessModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, UpdateRoleModel>> updateRole({
    required String budgetId,
    required String memberId,
    required String role,
  }) async {
    final path = NetworkConfigs.updateBudgetShareRole
        .replaceAll(':budgetId', budgetId)
        .replaceAll(':memberId', memberId);
    return _networkClient.patch(
      path,
      data: {'role': role},
      fromJson: (json) => UpdateRoleModel.fromJson(json['share'] as Map<String, dynamic>? ?? {}),
    );
  }
}
