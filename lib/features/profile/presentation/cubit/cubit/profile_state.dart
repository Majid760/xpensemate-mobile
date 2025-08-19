import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class ProfileState extends Equatable {

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.isProfileComplete = false,
    this.isUpdating = false,
    this.imageFile,
  });
  final ProfileStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isProfileComplete;
  final bool isUpdating;
  final File? imageFile;

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isProfileComplete,
    bool? isUpdating,
    File? imageFile,

  }) => ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      imageFile: imageFile ?? this.imageFile,
      errorMessage: errorMessage ?? this.errorMessage,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isUpdating: isUpdating ?? this.isUpdating,
    );

  @override
  List<Object?> get props => [
        status,
        user,
        imageFile,
        errorMessage,
        isProfileComplete,
        isUpdating,
      ];

  String get displayName => user?.name?.isNotEmpty ?? false
      ? user!.name!
      : user?.email.split('@').first ?? '';

  String get initials => user?.name?.isNotEmpty ?? false
      ? user!.name!.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
      : user?.email.isNotEmpty ?? false
          ? user!.email[0].toUpperCase()
          : '';

  bool get hasProfileImage =>
      user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty;
}