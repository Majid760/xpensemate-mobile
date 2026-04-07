import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';

class BudgetShareModel extends BudgetShareEntity {
  const BudgetShareModel({
    required super.id,
    required super.budgetId,
    required super.sharedWith,
    super.acceptedAt,
    required super.createdAt,
    required super.inviteToken,
    super.inviteTokenExpires,
    super.invitedAt,
    required super.isDeleted,
    super.lastViewedAt,
    required super.monthlyLimit,
    required super.ownerId,
    super.revokedAt,
    required super.role,
    required super.status,
    required super.updatedAt,
  });

  factory BudgetShareModel.fromJson(Map<String, dynamic> json) => BudgetShareModel(
      id: json['_id'] as String? ?? '',
      budgetId: json['budget_id'] as String? ?? '',
      sharedWith: json['shared_with'] as String? ?? '',
      acceptedAt: json['accepted_at'] != null ? DateTime.tryParse(json['accepted_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
      inviteToken: json['invite_token'] as String? ?? '',
      inviteTokenExpires: json['invite_token_expires'] != null ? DateTime.tryParse(json['invite_token_expires'] as String) : null,
      invitedAt: json['invited_at'] != null ? DateTime.tryParse(json['invited_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      lastViewedAt: json['last_viewed_at'] != null ? DateTime.tryParse(json['last_viewed_at'] as String) : null,
      monthlyLimit: (json['monthly_limit'] as num?)?.toDouble() ?? 0.0,
      ownerId: json['owner_id'] as String? ?? '',
      revokedAt: json['revoked_at'] != null ? DateTime.tryParse(json['revoked_at'] as String) : null,
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now() : DateTime.now(),
    );
}

class BudgetShareResultModel extends BudgetShareResultEntity {
  const BudgetShareResultModel({
    required BudgetShareModel super.share,
    required super.inviteLink,
  });

  factory BudgetShareResultModel.fromJson(Map<String, dynamic> json) => BudgetShareResultModel(
      share: BudgetShareModel.fromJson(json['share'] as Map<String, dynamic>? ?? {}),
      inviteLink: json['inviteLink'] as String? ?? '',
    );
}
