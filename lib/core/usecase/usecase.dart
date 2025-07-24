import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';

/// Abstract class for all use cases
/// [Type] is the return type of the use case
/// [Params] is the parameters required by the use case
abstract class UseCase<Type, Params> {

  Future<Either<Failure, Type>> call(Params params);
}

/// Class to handle use cases that don't require parameters
class NoParams {
  const NoParams();
}

/// Extension to make it easier to work with Either from Future
extension EitherX<L, R> on Either<L, R> {
  /// Gets the right value or throws an exception
  R getRight() => fold(
        (l) => throw Exception('Expected Right but got Left: $l'),
        (r) => r,
      );

  /// Gets the left value or throws an exception
  L getLeft() => fold(
        (l) => l,
        (r) => throw Exception('Expected Left but got Right: $r'),
      );
}

/// Extension to handle Future with Either
extension FutureEither<L, R> on Future<Either<L, R>> {
  /// Handles the result of a future that returns Either
  Future<Either<L, R2>> thenRight<R2>(
    Future<Either<L, R2>> Function(R) f,
  ) async => then((either) => either.fold(
          (l) => Future.value(Left(l)),
          f,
        ),);

  /// Handles the error case of a future that returns Either
  Future<Either<L, R>> handleError(
    Either<L, R> Function(dynamic error, StackTrace stackTrace) onError,
  ) async {
    try {
      return await this;
    } on Exception catch (error, stackTrace) {
      return onError(error, stackTrace);
    }
  }
}
