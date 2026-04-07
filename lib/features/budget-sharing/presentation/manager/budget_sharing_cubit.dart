import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/invite_user_usecase.dart';
import 'package:xpensemate/features/budget-sharing/presentation/manager/budget_sharing_state.dart';

class BudgetSharingCubit extends Cubit<BudgetSharingState> {
  BudgetSharingCubit(this._inviteUserUseCase) : super(BudgetSharingInitial());

  final InviteUserUseCase _inviteUserUseCase;

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
}
