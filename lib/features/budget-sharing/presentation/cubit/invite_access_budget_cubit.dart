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




// this is my budget screen , now the budget has the sharing feature a budget can share with familty member etc, so make some nice chaanges to current ui which can handle the sharing feature , the sharing feature has following functionalities



// 1) budget owner can share the its budget with it family member etc via email/name search so ui must provide the sharing ui etc

// 2) another user can see all his/her peding budgets share by another person, and can accpt or decline etc, i also want a minor change such budget show who is creator etc and editor i mean role/actor of budget

// 3) revokeaccess an owner of budget can revoke access from a specific person , so i need ui for this too

// 4) and owner of budget can update the role tool of any invitee of budget

//  and these are some reading -Analytics UI requirment 

// 1) all members of a budget and their role (name, email and avatar) 

// 2)  pending budget invites sent by owner

// 3) Invites received by the current user (across all budgets).

// 4) All budgets shared with the current user (accepted).

// 5) Per-member contribution breakdown for a budget.
//    * Returns how much each member has spent.

// 6) Paginated activity feed for a budget (most recent first).

// the ui may contail whole seprate secreen bottom sheet , pop dialog, anything which must fulfil all abot functionalaties and requirements in modern elegane , etc so make sure the ui must be in reactjs or any other technology which you can render , so i can view the ui and copy it to my flutter app

