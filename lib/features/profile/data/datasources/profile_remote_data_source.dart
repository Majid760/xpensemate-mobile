import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart' as path;
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<Failure, UserModel>> updateProfile(Map<String, dynamic> data);

  Future<Either<Failure, String?>> updateProfileImage({
    required File imageFile,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);
  final NetworkClient _client;

  @override
  Future<Either<Failure, UserModel>> updateProfile(Map<String, dynamic> data) =>
      _client.put(
        NetworkConfigs.updateProfile, // Use /settings/update-user endpoint
        data: data,
        fromJson: UserModel.fromJson,
      );

  @override
  Future<Either<Failure, String?>> updateProfileImage({
    required File imageFile,
  }) async {
    try {
      final formData = FormData();
      final fileName = path.basename(imageFile.path);
      // Set appropriate content type based on file extension
      final fileExtension = path.extension(fileName).toLowerCase();
      final contentType = _getContentTypeFromExtension(fileExtension);
      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: contentType,
      );
      formData.files.add(MapEntry('photo', multipartFile));
      final response = await _client.post(
        NetworkConfigs
            .updateProfilePhoto, // Use /settings/upload-profile endpoint
        data: formData,
        fromJson: (Map<String, dynamic> json) => json, // Return raw JSON,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.fold(
        (failure) async => Left(failure),
        (json) async => Right(json['url'] as String?),
      );
    } on Exception catch (e) {
      return Left(e.toFailure());
    }
  }

// Helper method - can be placed at the top of your class or in a utils file
  static MediaType _getContentTypeFromExtension(String extension) =>
      switch (extension.toLowerCase()) {
        '.jpg' || '.jpeg' => MediaType('image', 'jpeg'),
        '.png' => MediaType('image', 'png'),
        '.gif' => MediaType('image', 'gif'),
        '.webp' => MediaType('image', 'webp'),
        _ => MediaType('image', 'jpeg'), // fallback
      };
}
