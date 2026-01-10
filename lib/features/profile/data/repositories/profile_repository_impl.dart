import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/service/storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart' show LogExt;
import 'package:xpensemate/features/auth/data/services/auth_service.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(
    this.remoteDataSource,
    this.authService,
    this.storageService,
  );

  final ProfileRemoteDataSource remoteDataSource;
  final AuthService authService;
  final StorageService storageService;

  static const String _themeStorageKey = 'app_theme_mode';

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final result = await remoteDataSource.updateProfile(data);
    return await result.fold(
      (failure) async => Left(failure),
      (userModel) async {
        final entity = userModel.toEntity();
        await authService.saveUserToStorage(entity);
        return Right(entity);
      },
    );
  }

  @override
  Future<Either<Failure, String?>> updateProfileImage({
    required File imageFile,
  }) async {
    final result = await remoteDataSource.updateProfileImage(
      imageFile: imageFile,
    );
    return result;
  }

  @override
  Future<Either<Failure, ThemeMode>> getTheme() async {
    try {
      final savedThemeString = await storageService.get<String>(
        key: _themeStorageKey,
      );
      if (savedThemeString != null) {
        return Right(
          ThemeMode.values.firstWhere(
            (e) => e.toString() == savedThemeString,
            orElse: () => ThemeMode.system,
          ),
        );
      }
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return const Right(ThemeMode.system);
    }
    return const Right(ThemeMode.system);
  }

  @override
  Future<Either<Failure, void>> saveTheme(ThemeMode themeMode) async {
    try {
      await storageService.put<String>(
        key: _themeStorageKey,
        value: themeMode.toString(),
      );
    } on Exception catch (e) {
      logE("exception occurs at saveTheme $e");
      return Left(e.toFailure());
    }
    return const Right(null);
  }
}
