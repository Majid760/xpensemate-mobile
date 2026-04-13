import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget-sharing/data/datasources/budget_sharing_remote_data_source.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/decline_invite_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/revoke_access_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/update_role_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/user_search_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class BudgetSharingRepositoryImpl implements BudgetSharingRepository {
  BudgetSharingRepositoryImpl(this.remoteDataSource);

  final BudgetSharingRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserSearchPaginationEntity>> searchUsers({
    required String query,
    required int page,
    required int limit,
  }) async =>
      remoteDataSource.searchUsers(
        query: query,
        page: page,
        limit: limit,
      );

  @override
  Future<Either<Failure, BudgetShareResultEntity>> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    double? monthlyLimit,
  }) async => remoteDataSource.inviteUser(
      budgetId: budgetId,
      inviteeId: inviteeId,
      role: role,
      monthlyLimit: monthlyLimit,
    );

  @override
  Future<Either<Failure, BudgetShareEntity>> acceptInvite({
    required String budgetId,
  }) async => remoteDataSource.acceptInvite(budgetId: budgetId);

  @override
  Future<Either<Failure, DeclineInviteEntity>> declineInvite({
    required String budgetId,
  }) async => remoteDataSource.declineInvite(budgetId: budgetId);

  @override
  Future<Either<Failure, RevokeAccessEntity>> revokeAccess({
    required String budgetId,
    required String memberId,
  }) async => remoteDataSource.revokeAccess(budgetId: budgetId, memberId: memberId);

  @override
  Future<Either<Failure, UpdateRoleEntity>> updateRole({
    required String budgetId,
    required String memberId,
    required String role,
  }) async => remoteDataSource.updateRole(
        budgetId: budgetId,
        memberId: memberId,
        role: role,
      );
}
