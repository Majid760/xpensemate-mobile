import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmailAndPassword extends UseCase<User, RegisterWithEmailAndPasswordParams> {
  RegisterWithEmailAndPassword(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(
    RegisterWithEmailAndPasswordParams params,
  ) async {
    final result = await repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
    return result;
  }
}

class RegisterWithEmailAndPasswordParams {
  const RegisterWithEmailAndPasswordParams({
    required this.email,
    required this.password,
    this.name,
  });
  final String email;
  final String password;
  final String? name;
}
