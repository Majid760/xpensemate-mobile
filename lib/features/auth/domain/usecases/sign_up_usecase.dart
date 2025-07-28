import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase
    extends UseCase<User, SignUpUseCaseParams> {
  SignUpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(
    SignUpUseCaseParams params,
  ) async {
    final result = await repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
    return result;
  }
}

class SignUpUseCaseParams {
  const SignUpUseCaseParams({
    required this.email,
    required this.password,
    this.name,
  });
  final String email;
  final String password;
  final String? name;
}
