import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/budget-sharing/data/models/budget_share_model.dart';

abstract class BudgetSharingRemoteDataSource {
  Future<Either<Failure, BudgetShareResultModel>> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    double? monthlyLimit,
  });

  Future<Either<Failure, BudgetShareModel>> acceptInvite({
    required String budgetId,
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
}
