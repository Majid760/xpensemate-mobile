import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class AcceptInviteUseCase extends UseCase<BudgetShareEntity, AcceptInviteParams> {
  AcceptInviteUseCase(this.repository);

  final BudgetSharingRepository repository;

  @override
  Future<Either<Failure, BudgetShareEntity>> call(AcceptInviteParams params) =>
      repository.acceptInvite(
        budgetId: params.budgetId,
      );
}

class AcceptInviteParams {
  const AcceptInviteParams({
    required this.budgetId,
  });

  final String budgetId;
}
