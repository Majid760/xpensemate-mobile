import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class AuthenticateWithBiometricsUseCase implements UseCase<UserEntity, NoParams> {
  AuthenticateWithBiometricsUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async => repository.authenticateWithBiometrics();
}
