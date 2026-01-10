import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';
import 'package:xpensemate/features/profile/domain/usecases/profile_use_cases_holder.dart';
import 'package:xpensemate/features/profile/domain/usecases/use_cases_export.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._authCubit,
    this._profileUseCasesHolder,
  ) : super(const ProfileInitial()) {
    AppLogger.breadcrumb('Initializing ProfileCubit...');
    _initialize();
  }

  final ProfileUseCasesHolder _profileUseCasesHolder;
  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  Future<void> _initialize() async {
    emit(const ProfileLoading());

    // 1. Initial user state
    final authState = _authCubit.state;
    UserEntity? user;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }

    // 2. Load theme
    var themeMode = ThemeMode.system;
    final themeResult =
        await _profileUseCasesHolder.getThemeUseCase(const NoParams());
    themeResult.fold((_) => null, (mode) => themeMode = mode);

    if (user != null) {
      emit(ProfileLoaded(user: user, themeMode: themeMode));
    } else {
      emit(const ProfileError('User session not found'));
    }

    // 3. Listen for changes
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(user: authState.user));
        } else {
          emit(ProfileLoaded(user: authState.user, themeMode: themeMode));
        }
      } else if (authState is AuthUnauthenticated) {
        emit(const ProfileInitial());
      }
    });
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    try {
      String? photoUrl;
      if (currentState.imageFile != null) {
        photoUrl = await updateProfileImage(currentState.imageFile);
      }

      if (photoUrl != null) data["profilePhotoUrl"] = photoUrl;

      final result = await _profileUseCasesHolder.updateProfileUseCase(
        UpdateProfileParams(data),
      );

      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isUpdating: false,
            message: failure.message,
          ),
        ),
        (user) => emit(
          currentState.copyWith(
            user: user,
            isUpdating: false,
            message: 'updated',
          ),
        ),
      );
    } on Exception catch (e) {
      emit(
        currentState.copyWith(
          isUpdating: false,
          message: e.toString(),
        ),
      );
    }
  }

  Future<String?> updateProfileImage(File? file) async {
    if (file == null) return null;

    final result = await _profileUseCasesHolder.updateProfileImageUseCase(
      UpdateProfileImageParams(imageFile: file),
    );

    return result.fold(
      (failure) => null,
      (url) => url,
    );
  }

  void setImageFile(File? file) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(imageFile: file));
    }
  }

  void clearError() {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith());
    }
  }

  Future<void> toggleTheme({required bool isDark}) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await updateTheme(newMode);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      if (currentState.themeMode == mode) return;

      final result = await _profileUseCasesHolder.saveThemeUseCase(mode);
      result.fold(
        (failure) => null, // Handle error if needed
        (_) => emit(currentState.copyWith(themeMode: mode)),
      );
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

/// Extension to easily access ProfileCubit in widgets
extension ProfileCubitExtension on BuildContext {
  ProfileCubit get profileCubit => read<ProfileCubit>();
}
