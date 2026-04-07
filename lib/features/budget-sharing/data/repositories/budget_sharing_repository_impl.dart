import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/budget-sharing/data/datasources/budget_sharing_remote_data_source.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class BudgetSharingRepositoryImpl implements BudgetSharingRepository {
  BudgetSharingRepositoryImpl(this.remoteDataSource);

  final BudgetSharingRemoteDataSource remoteDataSource;

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
}
