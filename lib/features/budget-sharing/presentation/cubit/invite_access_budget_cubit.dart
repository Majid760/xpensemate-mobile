import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/accept_invite_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/decline_invite_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/invite_user_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/revoke_access_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/update_role_usecase.dart';
import 'package:xpensemate/features/budget-sharing/presentation/cubit/invite_access_budget_state.dart';

class InviteAccessBudgetCubit extends Cubit<InviteAccessBudgetCubitState> {
  InviteAccessBudgetCubit(
    this._inviteUserUseCase,
    this._acceptInviteUseCase,
    this._declineInviteUseCase,
    this._revokeAccessUseCase,
    this._updateRoleUseCase,
  ) : super(InviteAccessBudgetCubitInitial());

  final InviteUserUseCase _inviteUserUseCase;
  final AcceptInviteUseCase _acceptInviteUseCase;
  final DeclineInviteUseCase _declineInviteUseCase;
  final RevokeAccessUseCase _revokeAccessUseCase;
  final UpdateRoleUseCase _updateRoleUseCase;

  // invite user (owner invites user)
  Future<void> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    required double monthlyLimit,
  }) async {
    emit(InviteAccessBudgetCubitLoading());
    final result = await _inviteUserUseCase(
      InviteUserParams(
        budgetId: budgetId,
        inviteeId: inviteeId,
        role: role,
        monthlyLimit: monthlyLimit,
      ),
    );

    result.fold(
      (failure) => emit(InviteAccessBudgetCubitError(failure.message)),
      (resultEntity) => emit(InviteAccessBudgetCubitSuccess(inviteUserResult: resultEntity)),
    );
  }
  // accept invite (invitee of budget can accept)
  Future<void> acceptInvite(String budgetId) async {
    emit(InviteAccessBudgetCubitLoading());
    final result = await _acceptInviteUseCase(
      AcceptInviteParams(budgetId: budgetId),
    );

    result.fold(
      (failure) => emit(InviteAccessBudgetCubitError(failure.message)),
      (resultEntity) => emit(InviteAccessBudgetCubitSuccess(acceptInviteResult: resultEntity)),
    );
  }
  // decline invite (invitee of budget can decline)
  Future<void> declineInvite(String budgetId) async {
    emit(InviteAccessBudgetCubitLoading());
    final result = await _declineInviteUseCase(
      DeclineInviteParams(budgetId: budgetId),
    );

    result.fold(
      (failure) => emit(InviteAccessBudgetCubitError(failure.message)),
      (resultEntity) => emit(InviteAccessBudgetCubitSuccess(declineInviteResult: resultEntity)),
    );
  }

  // revoke access (owner revokes member's access)
  Future<void> revokeAccess(String budgetId, String memberId) async {
    emit(InviteAccessBudgetCubitLoading());
    final result = await _revokeAccessUseCase(
      RevokeAccessParams(budgetId: budgetId, memberId: memberId),
    );

    result.fold(
      (failure) => emit(InviteAccessBudgetCubitError(failure.message)),
      (resultEntity) => emit(InviteAccessBudgetCubitSuccess(revokeAccessResult: resultEntity)),
    );
  }

  // update role (owner updates role of member)
  Future<void> updateRole(String budgetId, String memberId, String role) async {
    emit(InviteAccessBudgetCubitLoading());
    final result = await _updateRoleUseCase(
      UpdateRoleParams(budgetId: budgetId, memberId: memberId, role: role),
    );
    result.fold(
      (failure) => emit(InviteAccessBudgetCubitError(failure.message)),
      (resultEntity) => emit(InviteAccessBudgetCubitSuccess(updateRoleResult: resultEntity)),
    );
  }
}

