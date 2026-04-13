import 'package:equatable/equatable.dart';

class UserSearchEntity extends Equatable {

  const UserSearchEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePhotoUrl,
    required this.isVerified,
    this.about,
  });
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePhotoUrl;
  final bool isVerified;
  final String? about;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        profilePhotoUrl,
        isVerified,
        about,
      ];
}

class UserSearchPaginationEntity extends Equatable {

  const UserSearchPaginationEntity({
    required this.users,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });
  final List<UserSearchEntity> users;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  @override
  List<Object?> get props => [users, page, limit, total, hasMore];
}
