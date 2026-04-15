import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/decline_invite_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/revoke_access_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/update_role_entity.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/user_search_entity.dart';

enum InviteAccessStatus { initial, loading, loaded, searching, searchLoaded, searchError, error, success }

class InviteAccessBudgetCubitState extends Equatable {

  const InviteAccessBudgetCubitState({
    this.status = InviteAccessStatus.initial,
    this.message,
    this.searchResults = const [],
    this.searchPage = 1,
    this.hasMoreSearchResults = false,
    this.invitingUserIds = const {},
    this.invitedUserIds = const {},
    this.inviteUserResult,
    this.acceptInviteResult,
    this.declineInviteResult,
    this.revokeAccessResult,
    this.updateRoleResult,
  });
  final InviteAccessStatus status;
  final String? message;
  final List<UserSearchEntity> searchResults;
  final int searchPage;
  final bool hasMoreSearchResults;
  final Set<String> invitingUserIds;
  final Set<String> invitedUserIds;
  final BudgetShareResultEntity? inviteUserResult;
  final BudgetShareEntity? acceptInviteResult;
  final DeclineInviteEntity? declineInviteResult;
  final RevokeAccessEntity? revokeAccessResult;
  final UpdateRoleEntity? updateRoleResult;

  InviteAccessBudgetCubitState copyWith({
    InviteAccessStatus? status,
    String? message,
    List<UserSearchEntity>? searchResults,
    int? searchPage,
    bool? hasMoreSearchResults,
    Set<String>? invitingUserIds,
    Set<String>? invitedUserIds,
    BudgetShareResultEntity? inviteUserResult,
    BudgetShareEntity? acceptInviteResult,
    DeclineInviteEntity? declineInviteResult,
    RevokeAccessEntity? revokeAccessResult,
    UpdateRoleEntity? updateRoleResult,
  }) => InviteAccessBudgetCubitState(
      status: status ?? this.status,
      message: message ?? this.message,
      searchResults: searchResults ?? this.searchResults,
      searchPage: searchPage ?? this.searchPage,
      hasMoreSearchResults: hasMoreSearchResults ?? this.hasMoreSearchResults,
      invitingUserIds: invitingUserIds ?? this.invitingUserIds,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      inviteUserResult: inviteUserResult ?? this.inviteUserResult,
      acceptInviteResult: acceptInviteResult ?? this.acceptInviteResult,
      declineInviteResult: declineInviteResult ?? this.declineInviteResult,
      revokeAccessResult: revokeAccessResult ?? this.revokeAccessResult,
      updateRoleResult: updateRoleResult ?? this.updateRoleResult,
    );

  @override
  List<Object?> get props => [
        status,
        message,
        searchResults,
        searchPage,
        hasMoreSearchResults,
        invitingUserIds,
        invitedUserIds,
        inviteUserResult,
        acceptInviteResult,
        declineInviteResult,
        revokeAccessResult,
        updateRoleResult,
      ];
}
