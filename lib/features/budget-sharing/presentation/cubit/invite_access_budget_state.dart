import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/decline_invite_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/revoke_access_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/update_role_entity.dart';

abstract class InviteAccessBudgetCubitState extends Equatable {
  const InviteAccessBudgetCubitState();

  @override
  List<Object?> get props => [];
}
class InviteAccessBudgetCubitInitial extends InviteAccessBudgetCubitState {}

class InviteAccessBudgetCubitLoading extends InviteAccessBudgetCubitState {}

class InviteAccessBudgetCubitError extends InviteAccessBudgetCubitState {
  const InviteAccessBudgetCubitError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}


class InviteAccessBudgetCubitSuccess extends InviteAccessBudgetCubitState {
  const InviteAccessBudgetCubitSuccess({
    this.inviteUserResult,
    this.acceptInviteResult,
    this.declineInviteResult,
    this.revokeAccessResult,
    this.updateRoleResult,
  });

  final BudgetShareResultEntity? inviteUserResult;
  final BudgetShareEntity? acceptInviteResult;
  final DeclineInviteEntity? declineInviteResult;
  final RevokeAccessEntity? revokeAccessResult;
  final UpdateRoleEntity? updateRoleResult;

  InviteAccessBudgetCubitSuccess copyWith({
    BudgetShareResultEntity? inviteUserResult,
    BudgetShareEntity? acceptInviteResult,
    DeclineInviteEntity? declineInviteResult,
    RevokeAccessEntity? revokeAccessResult,
    UpdateRoleEntity? updateRoleResult,
  }) => InviteAccessBudgetCubitSuccess(
      inviteUserResult: inviteUserResult ?? this.inviteUserResult,
      acceptInviteResult: acceptInviteResult ?? this.acceptInviteResult,
      declineInviteResult: declineInviteResult ?? this.declineInviteResult,
      revokeAccessResult: revokeAccessResult ?? this.revokeAccessResult,
      updateRoleResult: updateRoleResult ?? this.updateRoleResult,
    );

  @override
  List<Object?> get props => [
        inviteUserResult,
        acceptInviteResult,
        declineInviteResult,
        revokeAccessResult,
        updateRoleResult,
      ];
}


