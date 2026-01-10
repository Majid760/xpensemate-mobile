import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/service/storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/profile/domain/usecases/profile_use_cases_holder.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
      this._authCubit, this._storageService, this._profileUseCasesHolder)
      : super(const ProfileState()) {
    AppLogger.breadcrumb('Initializing ProfileCubit...');
    _initializeProfile();
    _listenToAuthChanges();
    _loadTheme();
  }

  final ProfileUseCasesHolder _profileUseCasesHolder;
  final AuthCubit _authCubit;
  final StorageService _storageService;
  static const String _themeStorageKey = 'app_theme_mode';

  /// Initialize profile with current user data from AuthCubit
  void _initializeProfile() {
    final currentUser = _authCubit.state is AuthAuthenticated
        ? (_authCubit.state as AuthAuthenticated).user
        : null;
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
      if (authState is AuthAuthenticated) {
        // Update profile when auth state changes
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            user: authState.user,
            isProfileComplete: _isProfileComplete(authState.user!),
          ),
        );
      } else if (authState is AuthUnauthenticated) {
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
      final rslt = await _profileUseCasesHolder.updateProfileUseCase
          .call(UpdateProfileParams(data));
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
        AppLogger.userAction('update_profile', {
          'has_image': data['profilePhotoUrl'] != null,
          'fields_count': data.length,
        });
        emit(state.copyWith(user: user, isUpdating: false, message: 'updated'));
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
      final result = await _profileUseCasesHolder.updateProfileImageUseCase
          .call(UpdateProfileImageParams(imageFile: file));
      result.fold(
        (failure) {
          AppLogger.breadcrumb('Image upload failed: ${failure.message}');
          uploadedUrl = null;
        },
        (url) {
          AppLogger.breadcrumb('Image upload successful');
          AppLogger.userAction('update_profile_image');
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

  /// Toggle between light and dark mode
  Future<void> toggleTheme({required bool isDark}) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: newMode));
    await _saveTheme(newMode);
  }

  /// Set a specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    if (state.themeMode != mode) {
      emit(state.copyWith(themeMode: mode));
      await _saveTheme(mode);
    }
  }

  /// Load persisted theme
  Future<void> _loadTheme() async {
    try {
      final savedThemeString = await _storageService.get<String>(
        key: _themeStorageKey,
      );

      if (savedThemeString != null) {
        final mode = ThemeMode.values.firstWhere(
          (e) => e.toString() == savedThemeString,
          orElse: () => ThemeMode.system,
        );
        emit(state.copyWith(themeMode: mode));
      }
    } on Exception catch (e) {
      // If error occurs, fallback to system default (initial state)
      debugPrint('Error loading theme: $e');
    }
  }

  /// Save theme to storage
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      await _storageService.put<String>(
        key: _themeStorageKey,
        value: mode.toString(),
      );
    } on Exception catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}

/// Extension to easily access ProfileCubit in widgets
extension ProfileCubitExtension on BuildContext {
  ProfileCubit get profileCubit => read<ProfileCubit>();
}
