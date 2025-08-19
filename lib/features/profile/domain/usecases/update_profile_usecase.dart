import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase
    extends UseCase<UserEntity, UpdateProfileParams> {
  UpdateProfileUseCase(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) =>
      repository.updateProfile(
        params.data,
        
      );
}

class UpdateProfileParams {
  const UpdateProfileParams(this.data);

final Map<String, dynamic> data;
}


