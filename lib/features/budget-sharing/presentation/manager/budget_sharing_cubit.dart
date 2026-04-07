import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/accept_invite_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/invite_user_usecase.dart';
import 'package:xpensemate/features/budget-sharing/presentation/manager/budget_sharing_state.dart';

class BudgetSharingCubit extends Cubit<BudgetSharingState> {
  BudgetSharingCubit(this._inviteUserUseCase, this._acceptInviteUseCase) : super(BudgetSharingInitial());

  final InviteUserUseCase _inviteUserUseCase;
  final AcceptInviteUseCase _acceptInviteUseCase;

  Future<void> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    required double monthlyLimit,
  }) async {
    emit(BudgetSharingLoading());
    final result = await _inviteUserUseCase(
      InviteUserParams(
        budgetId: budgetId,
        inviteeId: inviteeId,
        role: role,
        monthlyLimit: monthlyLimit,
      ),
    );

    result.fold(
      (failure) => emit(BudgetSharingError(failure.message)),
      (resultEntity) => emit(BudgetSharingSuccess(resultEntity)),
    );
  }

  Future<void> acceptInvite(String budgetId) async {
    emit(AcceptInviteLoading());
    final result = await _acceptInviteUseCase(
      AcceptInviteParams(budgetId: budgetId),
    );

    result.fold(
      (failure) => emit(AcceptInviteError(failure.message)),
      (resultEntity) => emit(AcceptInviteSuccess(resultEntity)),
    );
  }
}
