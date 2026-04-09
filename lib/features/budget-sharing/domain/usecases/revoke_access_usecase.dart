import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/revoke_access_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class RevokeAccessUseCase extends UseCase<RevokeAccessEntity, RevokeAccessParams> {
  RevokeAccessUseCase(this.repository);

  final BudgetSharingRepository repository;

  @override
  Future<Either<Failure, RevokeAccessEntity>> call(RevokeAccessParams params) =>
      repository.revokeAccess(
        budgetId: params.budgetId,
        memberId: params.memberId,
      );
}

class RevokeAccessParams {
  const RevokeAccessParams({
    required this.budgetId,
    required this.memberId,
  });

  final String budgetId;
  final String memberId;
}
