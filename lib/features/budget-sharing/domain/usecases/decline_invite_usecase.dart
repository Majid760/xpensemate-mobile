import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/decline_invite_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class DeclineInviteUseCase extends UseCase<DeclineInviteEntity, DeclineInviteParams> {
  DeclineInviteUseCase(this.repository);

  final BudgetSharingRepository repository;

  @override
  Future<Either<Failure, DeclineInviteEntity>> call(DeclineInviteParams params) =>
      repository.declineInvite(
        budgetId: params.budgetId,
      );
}

class DeclineInviteParams {
  const DeclineInviteParams({
    required this.budgetId,
  });

  final String budgetId;
}
