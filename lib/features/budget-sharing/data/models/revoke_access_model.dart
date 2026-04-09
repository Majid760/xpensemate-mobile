import 'package:xpensemate/features/budget-sharing/domain/entities/revoke_access_entity.dart';

class RevokeAccessModel extends RevokeAccessEntity {
  const RevokeAccessModel({
    required super.message,
  });

  factory RevokeAccessModel.fromJson(Map<String, dynamic> json) => RevokeAccessModel(
        message: json['message'] as String? ?? '',
      );
}
