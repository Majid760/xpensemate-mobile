import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';


class VerifyEmail extends UseCase<void, VerifyEmailParams> {

   VerifyEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(VerifyEmailParams params) async => repository.verifyEmail(params.code);
}

class VerifyEmailParams {
  const VerifyEmailParams({required this.code});
  final String code;
}