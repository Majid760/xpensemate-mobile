import 'package:xpensemate/features/auth/domain/entities/user.dart';

class UserModel extends User {

  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    super.isEmailVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromEntity(User user) => UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      isEmailVerified: user.isEmailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );


  Map<String, dynamic> toJson() => {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };

  User toEntity() => User(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );


      @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];
  }


