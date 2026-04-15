import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/user_search_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/accept_invite_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/decline_invite_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/invite_user_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/revoke_access_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/search_users_usecase.dart';
import 'package:xpensemate/features/budget-sharing/domain/usecases/update_role_usecase.dart';
import 'package:xpensemate/features/budget-sharing/presentation/cubit/invite_access_budget_state.dart';

class InviteAccessBudgetCubit extends Cubit<InviteAccessBudgetCubitState> {
  InviteAccessBudgetCubit(
    this._inviteUserUseCase,
    this._acceptInviteUseCase,
    this._declineInviteUseCase,
    this._revokeAccessUseCase,
    this._updateRoleUseCase,
    this._searchUsersUseCase,
  ) : super(const InviteAccessBudgetCubitState()) {
        _pagingController.addListener(_showPaginationError);
  }

  final InviteUserUseCase _inviteUserUseCase;
  final AcceptInviteUseCase _acceptInviteUseCase;
  final DeclineInviteUseCase _declineInviteUseCase;
  final RevokeAccessUseCase _revokeAccessUseCase;
  final UpdateRoleUseCase _updateRoleUseCase;
  final SearchUsersUseCase _searchUsersUseCase;

  static const int _limit = 10;
  String filterQuery = '';


  late final _pagingController = PagingController<int, UserSearchEntity>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async => fetchUsers(pageKey, filterQuery),
  );
  PagingController<int, UserSearchEntity> get pagingController =>
      _pagingController;

  void searchUsers(String query) {
    if (filterQuery == query) return;
    filterQuery = query;
    _pagingController.refresh();
  }

    /// Fetches users for a specific page
  Future<List<UserSearchEntity>> fetchUsers(
    int pageKey,
    String filterQuery,
  ) async {
    final trimmedQuery = filterQuery.trim();
    if (trimmedQuery.length < 2) {
      return [];
    }
    AppLogger.breadcrumb('Fetching users page: $pageKey with query: $trimmedQuery...');
    try {
      final params = SearchUsersParams(
        page: pageKey,
        query: trimmedQuery,
      );
      final result = await _searchUsersUseCase(params);
      return result.fold(
        (failure) {
          AppLogger.breadcrumb('Fetch users failed: ${failure.message}');
          return [];
        },
        (paginationEntity) {
          AppLogger.breadcrumb(
            'Fetch users success (${paginationEntity.users.length} items)',
          );
          return paginationEntity.users;
        },
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.e('fetchUsers failed', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> close() {
    _pagingController.dispose();
    return super.close();
  }

  void _showPaginationError() {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      emit(
        state.copyWith(
          status: InviteAccessStatus.error,
          message: 'Something went wrong while fetching users.',
        ),
      );
    }
  }

  
  // invite user (owner invites user)
  Future<void> inviteUser({
    required String budgetId,
    required String inviteeId,
    required String role,
    required double monthlyLimit,
  }) async {
    if (state.invitingUserIds.contains(inviteeId) || 
        state.invitedUserIds.contains(inviteeId)) {
      return;
    }

    emit(state.copyWith(
      status: InviteAccessStatus.loading,
      invitingUserIds: {...state.invitingUserIds, inviteeId},
    ));

    final result = await _inviteUserUseCase(
      InviteUserParams(
        budgetId: budgetId,
        inviteeId: inviteeId,
        role: role,
        monthlyLimit: monthlyLimit,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: InviteAccessStatus.error,
        message: failure.message,
        invitingUserIds: state.invitingUserIds.where((id) => id != inviteeId).toSet(),
      )),
      (resultEntity) => emit(state.copyWith(
        status: InviteAccessStatus.success,
        inviteUserResult: resultEntity,
        invitingUserIds: state.invitingUserIds.where((id) => id != inviteeId).toSet(),
        invitedUserIds: {...state.invitedUserIds, inviteeId},
      )),
    );
  }

  // accept invite (invitee of budget can accept)
  Future<void> acceptInvite(String budgetId) async {
    emit(state.copyWith(status: InviteAccessStatus.loading));
    final result = await _acceptInviteUseCase(
      AcceptInviteParams(budgetId: budgetId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: InviteAccessStatus.error,
        message: failure.message,
      ),),
      (resultEntity) => emit(state.copyWith(
        status: InviteAccessStatus.success,
        acceptInviteResult: resultEntity,
      ),),
    );
  }

  // decline invite (invitee of budget can decline)
  Future<void> declineInvite(String budgetId) async {
    emit(state.copyWith(status: InviteAccessStatus.loading));
    final result = await _declineInviteUseCase(
      DeclineInviteParams(budgetId: budgetId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: InviteAccessStatus.error,
        message: failure.message,
      ),),
      (resultEntity) => emit(state.copyWith(
        status: InviteAccessStatus.success,
        declineInviteResult: resultEntity,
      ),),
    );
  }

  // revoke access (owner revokes member's access)
  Future<void> revokeAccess(String budgetId, String memberId) async {
    emit(state.copyWith(status: InviteAccessStatus.loading));
    final result = await _revokeAccessUseCase(
      RevokeAccessParams(budgetId: budgetId, memberId: memberId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: InviteAccessStatus.error,
        message: failure.message,
      ),),
      (resultEntity) => emit(state.copyWith(
        status: InviteAccessStatus.success,
        revokeAccessResult: resultEntity,
      ),),
    );
  }

  // update role (owner updates role of member)
  Future<void> updateRole(String budgetId, String memberId, String role) async {
    emit(state.copyWith(status: InviteAccessStatus.loading));
    final result = await _updateRoleUseCase(
      UpdateRoleParams(budgetId: budgetId, memberId: memberId, role: role),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: InviteAccessStatus.error,
        message: failure.message,
      ),),
      (resultEntity) => emit(state.copyWith(
        status: InviteAccessStatus.success,
        updateRoleResult: resultEntity,
      ),),
    );
  }
}
extension InviteAccessBudgetCubitX on BuildContext {
  InviteAccessBudgetCubit get inviteAccessBudgetCubit => read<InviteAccessBudgetCubit>();
}