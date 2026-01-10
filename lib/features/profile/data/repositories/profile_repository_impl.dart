import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/auth/data/services/auth_service.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remoteDataSource, this.authService);

  final ProfileRemoteDataSource remoteDataSource;
  final AuthService authService;

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
}
