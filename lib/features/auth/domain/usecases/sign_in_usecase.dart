import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';



class SignInWithEmailUseCase
    extends UseCase<User, SignInWithEmailUseCaseParams> {

  SignInWithEmailUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInWithEmailUseCaseParams params) async => repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
}


class SignInWithEmailUseCaseParams {

  const SignInWithEmailUseCaseParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}