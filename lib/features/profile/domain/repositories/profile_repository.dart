import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> data);

  Future<Either<Failure, String?>> updateProfileImage({required File imageFile});
}
