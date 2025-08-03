

import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';


class SendVerificationEmailUseCase
    extends UseCase<dynamic, SendVerificationEmailUseCaseParams> {
  SendVerificationEmailUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, dynamic>> call(
    SendVerificationEmailUseCaseParams params,
  ) => repository.sendVerificationEmail(params.email);
}

class SendVerificationEmailUseCaseParams {
  const SendVerificationEmailUseCaseParams({required this.email});
  final String email;
}
