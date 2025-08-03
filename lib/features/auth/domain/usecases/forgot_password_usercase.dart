import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';


class ForgotPasswordUseCase
    extends UseCase<void, ForgotPasswordUseCaseParams> {
  ForgotPasswordUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(
    ForgotPasswordUseCaseParams params,
  ) => repository.forgotPassword(params.email);
}

class ForgotPasswordUseCaseParams {
  const ForgotPasswordUseCaseParams({required this.email});
  final String email;
}
