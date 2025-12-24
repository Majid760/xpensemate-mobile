import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authCubit) : super(const ProfileState()) {
    AppLogger.breadcrumb('Initializing ProfileCubit...');
    _initializeProfile();
    _listenToAuthChanges();
  }

  final AuthCubit _authCubit;

  /// Initialize profile with current user data from AuthCubit
  void _initializeProfile() {
    final currentUser = _authCubit.user;
    if (currentUser != null) {
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: currentUser,
          isProfileComplete: _isProfileComplete(currentUser),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: 'No user data available',
        ),
      );
    }
  }

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    _authCubit.stream.listen((authState) {
      if (authState.isAuthenticated && authState.user != null) {
        // Update profile when auth state changes
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            user: authState.user,
            isProfileComplete: _isProfileComplete(authState.user!),
          ),
        );
      } else if (!authState.isAuthenticated) {
        // Clear profile data when user logs out
        emit(const ProfileState());
      }
    });
  }

  /// Check if user profile is complete
  bool _isProfileComplete(UserEntity user) =>
      (user.name?.isNotEmpty ?? false) &&
      user.email.isNotEmpty &&
      (user.profilePhotoUrl?.isNotEmpty ?? false);

  /// Update user profile information
  Future<void> updateProfile(Map<String, dynamic> data) async {
    AppLogger.breadcrumb('Updating profile...');
    if (state.user == null) {
      AppLogger.breadcrumb('Profile update aborted: state.user is null');
      return;
    }
    emit(state.copyWith(isUpdating: true));
    try {
      String? photoUrl;
      if (state.imageFile != null) {
        AppLogger.breadcrumb('Updating profile image first...');
        photoUrl = await updateProfileImage(state.imageFile);
      }
      // update the text data
      if (photoUrl != null) data["profilePhotoUrl"] = photoUrl;
      final rslt =
          await sl<UpdateProfileUseCase>().call(UpdateProfileParams(data));
      rslt.fold((failure) {
        AppLogger.breadcrumb('Profile update failed: ${failure.message}');
        emit(
          state.copyWith(
            message: failure.message,
            status: ProfileStatus.error,
            isUpdating: false,
          ),
        );
      }, (user) {
        AppLogger.breadcrumb('Profile update successful');
        emit(state.copyWith(user: user, isUpdating: false, message: 'updated'));
        // after update at in server side we need to update user in local storage
        _authCubit.updateUser(user);
      });
    } on Exception catch (e, s) {
      AppLogger.e('updateProfile failed', e, s);
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: 'Failed to update profile: $e',
          isUpdating: false,
        ),
      );
    }
  }

  /// Upload profile image and update user state. Returns uploaded URL or null.
  Future<String?> updateProfileImage(File? file) async {
    if (file == null) return null;
    AppLogger.breadcrumb('Uploading profile image...');
    String? uploadedUrl;
    try {
      final result = await sl<UpdateProfileImageUseCase>()
          .call(UpdateProfileImageParams(imageFile: state.imageFile!));
      result.fold(
        (failure) {
          AppLogger.breadcrumb('Image upload failed: ${failure.message}');
          uploadedUrl = null;
        },
        (url) {
          AppLogger.breadcrumb('Image upload successful');
          if (url != null && url.isNotEmpty) uploadedUrl = url;
        },
      );
    } on Exception catch (e, s) {
      AppLogger.e('updateProfileImage failed', e, s);
    }
    return uploadedUrl;
  }

  void setImageFile(File? file) =>
      emit(state.copyWith(imageFile: file, message: ''));

  /// Get user display name (fallback to email if no full name)
  String get displayName {
    if (state.user == null) return '';
    return state.user!.name!.isNotEmpty
        ? state.user!.name!
        : state.user!.email.split('@').first;
  }

  /// Get user initials for avatar fallback
  String get userInitials {
    if (state.user == null || state.user!.name!.isEmpty) return '';
    final nameParts = state.user!.name!.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return state.user!.name![0].toUpperCase();
  }

  /// Check if profile has image
  bool get hasProfileImage =>
      state.user?.profilePhotoUrl != null &&
      state.user!.profilePhotoUrl!.isNotEmpty;

  /// Clear any error messages
  void clearError() => emit(state.copyWith());
}

/// Extension to easily access ProfileCubit in widgets
extension ProfileCubitExtension on BuildContext {
  ProfileCubit get profileCubit => read<ProfileCubit>();
}
