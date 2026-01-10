import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.themeMode = ThemeMode.system,
    this.imageFile,
    this.isUpdating = false,
    this.message,
  });

  final UserEntity user;
  final ThemeMode themeMode;
  final File? imageFile;
  final bool isUpdating;
  final String? message;

  ProfileLoaded copyWith({
    UserEntity? user,
    ThemeMode? themeMode,
    File? imageFile,
    bool? isUpdating,
    String? message,
  }) =>
      ProfileLoaded(
        user: user ?? this.user,
        themeMode: themeMode ?? this.themeMode,
        imageFile: imageFile ?? this.imageFile,
        isUpdating: isUpdating ?? this.isUpdating,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => [
        user,
        themeMode,
        imageFile,
        isUpdating,
        message,
      ];

  String get displayName =>
      user.name?.isNotEmpty ?? false ? user.name! : user.email.split('@').first;

  String get initials => user.name?.isNotEmpty ?? false
      ? user.name!.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
      : user.email.isNotEmpty
          ? user.email[0].toUpperCase()
          : '';

  bool get hasProfileImage =>
      user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty;

  bool get isProfileComplete =>
      user.name != null &&
      user.name!.isNotEmpty &&
      user.profilePhotoUrl != null &&
      user.profilePhotoUrl!.isNotEmpty;
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
