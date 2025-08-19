import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<Failure, UserModel>> updateProfile(Map<String,dynamic> data);

  Future<Either<Failure, String?>> updateProfileImage({
    required File imageFile,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);
  final NetworkClient _client;

  @override
  Future<Either<Failure, UserModel>> updateProfile(Map<String,dynamic> data) => _client.put(
        NetworkConfigs.updateProfile, // Use /settings/update-user endpoint
        data: data,
        fromJson: UserModel.fromJson,
      );

  @override
  Future<Either<Failure, String?>> updateProfileImage({
    required File imageFile,
  }) async {
    final formData = FormData();
    final fileName = path.basename(imageFile.path);
    final multipartFile = await MultipartFile.fromFile(
      imageFile.path,
      filename: fileName,
    );
    formData.files.add(MapEntry('photo', multipartFile));

    return _client.post(
      NetworkConfigs.updateProfilePhoto, // Use /settings/upload-profile endpoint
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }
}


