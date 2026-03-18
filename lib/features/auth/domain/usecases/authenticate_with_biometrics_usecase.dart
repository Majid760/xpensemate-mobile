import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class AuthenticateWithBiometricsUseCase implements UseCase<bool, NoParams> {
  AuthenticateWithBiometricsUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async => repository.authenticateWithBiometrics();
}
