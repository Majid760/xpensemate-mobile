import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class InviteUserUseCase extends UseCase<BudgetShareResultEntity, InviteUserParams> {
  InviteUserUseCase(this.repository);

  final BudgetSharingRepository repository;

  @override
  Future<Either<Failure, BudgetShareResultEntity>> call(InviteUserParams params) =>
      repository.inviteUser(
        budgetId: params.budgetId,
        inviteeId: params.inviteeId,
        role: params.role,
        monthlyLimit: params.monthlyLimit,
      );
}

class InviteUserParams {
  const InviteUserParams({
    required this.budgetId,
    required this.inviteeId,
    required this.role,
    this.monthlyLimit,
  });

  final String budgetId;
  final String inviteeId;
  final String role;
  final double? monthlyLimit;
}
