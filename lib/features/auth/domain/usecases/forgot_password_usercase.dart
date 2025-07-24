import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';


class SendPasswordResetEmail
    extends UseCase<void, SendPasswordResetEmailParams> {
  SendPasswordResetEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(
    SendPasswordResetEmailParams params,
  ) async => repository.forgotPassword(params.email);
}

class SendPasswordResetEmailParams {
  const SendPasswordResetEmailParams({required this.email});
  final String email;
}
