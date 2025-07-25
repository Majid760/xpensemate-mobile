import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';


class VerifyEmailUseCase extends UseCase<void, VerifyEmailUseCaseParams> {

   VerifyEmailUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(VerifyEmailUseCaseParams params) async => repository.verifyEmail(params.code);
}

class VerifyEmailUseCaseParams {
  const VerifyEmailUseCaseParams({required this.code});
  final String code;
}