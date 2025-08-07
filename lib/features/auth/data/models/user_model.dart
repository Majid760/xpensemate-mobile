import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/l10n/app_localizations_en.dart';

class UserModel extends UserEntity {

  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    super.isEmailVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity user) => UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      isEmailVerified: user.isEmailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try{
    // Handle nested user structure
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    
    return UserModel(
      id: userData['_id'] as String? ?? userData['id'] as String? ?? '',
      email: userData['email'] as String,
      name: userData['firstName'] != null && userData['lastName'] != null
          ? '${userData['firstName']} ${userData['lastName']}'
          : userData['name'] as String?,
      photoUrl: userData['profilePhotoUrl'] as String? ?? userData['photoUrl'] as String?,
      isEmailVerified: userData['isVerified'] as bool? ?? userData['isEmailVerified'] as bool? ?? false,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'] as String)
          : null,
      updatedAt: userData['updatedAt'] != null
          ? DateTime.parse(userData['updatedAt'] as String)
          : null,
    );
    }on Exception catch(error){
      debugPrint('errror in user modle mapping $error');
      rethrow;
    }
  }


  Map<String, dynamic> toJson() => {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };

  UserEntity toEntity() => UserEntity(
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


