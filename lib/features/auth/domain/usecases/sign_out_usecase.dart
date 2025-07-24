import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class SignOut extends UseCase<void, NoParams> {

  SignOut(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async => repository.signOut();
}
