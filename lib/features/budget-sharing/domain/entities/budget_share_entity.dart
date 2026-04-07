import 'package:equatable/equatable.dart';

class BudgetShareEntity extends Equatable {
  const BudgetShareEntity({
    required this.id,
    required this.budgetId,
    required this.sharedWith,
    this.acceptedAt,
    required this.createdAt,
    required this.inviteToken,
    this.inviteTokenExpires,
    this.invitedAt,
    required this.isDeleted,
    this.lastViewedAt,
    required this.monthlyLimit,
    required this.ownerId,
    this.revokedAt,
    required this.role,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String budgetId;
  final String sharedWith;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final String inviteToken;
  final DateTime? inviteTokenExpires;
  final DateTime? invitedAt;
  final bool isDeleted;
  final DateTime? lastViewedAt;
  final double monthlyLimit;
  final String ownerId;
  final DateTime? revokedAt;
  final String role;
  final String status;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id, budgetId, sharedWith, acceptedAt, createdAt, inviteToken,
        inviteTokenExpires, invitedAt, isDeleted, lastViewedAt,
        monthlyLimit, ownerId, revokedAt, role, status, updatedAt,
      ];
}

class BudgetShareResultEntity extends Equatable {
  const BudgetShareResultEntity({
    required this.share,
    required this.inviteLink,
  });

  final BudgetShareEntity share;
  final String inviteLink;

  @override
  List<Object?> get props => [share, inviteLink];
}
