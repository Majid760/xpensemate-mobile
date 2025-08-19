import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remoteDataSource);

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> updateProfile(Map<String,dynamic> data) async {
   
    final result = await remoteDataSource.updateProfile(data);
    return result.map((model) => model.toEntity());
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


