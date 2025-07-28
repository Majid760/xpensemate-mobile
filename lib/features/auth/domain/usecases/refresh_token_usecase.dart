import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/auth_token.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';


class RefreshTokenUseCase extends UseCase<AuthToken, RefreshTokenUseCaseParams> {

  RefreshTokenUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthToken>> call(RefreshTokenUseCaseParams params) async => repository.refreshToken(params.refreshToken);
}

class RefreshTokenUseCaseParams {
  const RefreshTokenUseCaseParams({required this.refreshToken});
  final String refreshToken;
}

