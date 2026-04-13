import 'package:xpensemate/features/budget-sharing/domain/entities/user_search_entity.dart';

class UserSearchModel extends UserSearchEntity {
  const UserSearchModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.profilePhotoUrl,
    required super.isVerified,
    super.about,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) => UserSearchModel(
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      about: json['about'] as String?,
    );

  Map<String, dynamic> toJson() => {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePhotoUrl': profilePhotoUrl,
      'isVerified': isVerified,
      'about': about,
    };
}

class UserSearchPaginationModel extends UserSearchPaginationEntity {
  const UserSearchPaginationModel({
    required super.users,
    required super.page,
    required super.limit,
    required super.total,
    required super.hasMore,
  });

  factory UserSearchPaginationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final usersList = data['users'] as List<dynamic>? ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return UserSearchPaginationModel(
      users: usersList
          .map((e) => UserSearchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 10,
      total: pagination['total'] as int? ?? 0,
      hasMore: pagination['hasMore'] as bool? ?? false,
    );
  }
}
