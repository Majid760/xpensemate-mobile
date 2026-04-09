import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/update_role_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/repositories/budget_sharing_repository.dart';

class UpdateRoleUseCase extends UseCase<UpdateRoleEntity, UpdateRoleParams> {
  UpdateRoleUseCase(this.repository);

  final BudgetSharingRepository repository;

  @override
  Future<Either<Failure, UpdateRoleEntity>> call(UpdateRoleParams params) =>
      repository.updateRole(
        budgetId: params.budgetId,
        memberId: params.memberId,
        role: params.role,
      );
}

class UpdateRoleParams {
  const UpdateRoleParams({
    required this.budgetId,
    required this.memberId,
    required this.role,
  });

  final String budgetId;
  final String memberId;
  final String role;
}
