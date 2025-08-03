import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase extends UseCase<void, SignUpUseCaseParams> {
  SignUpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(
    SignUpUseCaseParams params,
  ) => repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
}

class SignUpUseCaseParams {
  const SignUpUseCaseParams({
    required this.email,
    required this.password,
    required this.fullName,
  });
  final String email;
  final String password;
  final String fullName;
}
