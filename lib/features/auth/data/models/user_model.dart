
import 'package:flutter/material.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {

  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.profilePhotoUrl,
    super.coverPhotoUrl,
    super.gender,
    super.about,
    super.phoneNumber,
    super.dob,
    super.isEmailVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity user) => UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profilePhotoUrl: user.profilePhotoUrl,
      coverPhotoUrl: user.coverPhotoUrl,
      gender: user.gender,
      about: user.about,
      phoneNumber: user.phoneNumber,
      dob: user.dob,
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
        profilePhotoUrl: userData['profilePhotoUrl'] as String? ?? userData['photoUrl'] as String?,
        coverPhotoUrl: userData['coverPhotoUrl'] as String?,
        isEmailVerified: userData['isVerified'] as bool? ?? userData['isEmailVerified'] as bool? ?? false,
        createdAt: userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'] as String)
            : null,
        updatedAt: userData['updatedAt'] != null
            ? DateTime.parse(userData['updatedAt'] as String)
            : null,
        gender: userData['gender'] as String?,
        about: userData['about'] as String?,
        phoneNumber: userData['phoneNumber'] as String?,
        dob: userData['dob'] as String?,
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
      if (profilePhotoUrl != null) 'photoUrl': profilePhotoUrl,
      'isEmailVerified': isEmailVerified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (about != null) 'about': about,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dob != null) 'dob': dob,
    };

  UserEntity toEntity() => UserEntity(
      id: id,
      email: email,
      name: name,
      profilePhotoUrl: profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl,
      gender: gender,
      about: about,
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
        profilePhotoUrl,
        coverPhotoUrl,
        gender,
        about,
        phoneNumber,
        dob,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];
  }


