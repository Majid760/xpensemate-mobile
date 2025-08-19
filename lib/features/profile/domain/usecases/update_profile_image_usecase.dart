import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileImageUseCase
    extends UseCase<String?, UpdateProfileImageParams> {
  UpdateProfileImageUseCase(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, String?>> call(
    UpdateProfileImageParams params,
  ) =>
      repository.updateProfileImage(imageFile: params.imageFile);
}

class UpdateProfileImageParams {
  const UpdateProfileImageParams({required this.imageFile});
  final File imageFile;
}


