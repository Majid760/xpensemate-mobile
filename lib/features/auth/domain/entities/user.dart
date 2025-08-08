import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';


class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.isEmailVerified = false,
    this.gender,
    this.about,
    this.phoneNumber,
    this.dob,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String email;
  final String? name;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final bool isEmailVerified;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String? about;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const empty = UserEntity(id: '', email: '');

  bool get isEmpty => this == UserEntity.empty;
  bool get isNotEmpty => this != UserEntity.empty;

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    bool? isEmailVerified,
    String? gender,
    String? phoneNumber,
    String? dob,
    String? about,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserEntity(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        gender: gender ?? this.gender,
        about: about ?? this.about,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        dob: dob ?? this.dob,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );


    UserModel get toModel => UserModel(
      id: id,
      email: email,
      name: name,
      gender: gender,
      about: about,
      profilePhotoUrl: profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl,
      phoneNumber: phoneNumber,
      dob: dob,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        gender,
        about,
        profilePhotoUrl,
        phoneNumber,
        dob,
        coverPhotoUrl,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];
}
