import 'package:equatable/equatable.dart';
import 'package:xpensemate/core/error/exceptions.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {

  const Failure({
    required this.message,
    this.stackTrace,
    this.error,
  });
  final String message;
  final StackTrace? stackTrace;
  final dynamic error;

  @override
  List<Object?> get props => [message, stackTrace, error];

  @override
  String toString() => 'Failure: $message';
}

/// Failure that represents a server-side error
class ServerFailure extends Failure {

  const ServerFailure({
    super.message = 'Server error occurred',
    this.statusCode,
    super.stackTrace,
    super.error,
  });
  final int? statusCode;

  @override
  String toString() => 'ServerFailure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Failure that represents a network connectivity issue
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.stackTrace,
    super.error,
  });
}

/// Failure that represents a timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out',
    super.stackTrace,
    super.error,
  });
}

/// Failure that represents an authentication error
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
    super.stackTrace,
    super.error,
  });
}

/// Failure that represents an authorization error
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'Not authorized',
    super.stackTrace,
    super.error,
  });
}

/// Failure that represents a validation error
class ValidationFailure extends Failure {

  const ValidationFailure({
    super.message = 'Validation failed',
    this.errors,
    super.stackTrace,
    super.error,
  });
  final Map<String, List<String>>? errors;

  @override
  String toString() => 'ValidationFailure: $message${errors != null ? '\nErrors: $errors' : ''}';
}

/// Failure that represents a not found error
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.stackTrace,
    super.error,
  });
}

/// Failure that represents a local data error (e.g., cache, storage)
class LocalDataFailure extends Failure {
  const LocalDataFailure({
    super.message = 'Local data error',
    super.stackTrace,
    super.error,
  });
}

/// Extension to convert exceptions to failures (mapper for data layer)
extension ExceptionToFailure on Exception {
  /// Converts any exception to a corresponding failure
  Failure toFailure() {
    if (this is NetworkException) {
      return NetworkFailure(
        message: (this as NetworkException).message,
        stackTrace: (this as NetworkException).stackTrace,
        error: (this as NetworkException).error,
      );
    } else if (this is ServerException) {
      return ServerFailure(
        message: (this as ServerException).message,
        statusCode: (this as ServerException).statusCode,
        stackTrace: (this as ServerException).stackTrace,
        error: (this as ServerException).error,
      );
    } else if (this is TimeoutException) {
      return TimeoutFailure(
        message: (this as TimeoutException).message,
        stackTrace: (this as TimeoutException).stackTrace,
        error: (this as TimeoutException).error,
      );
    } else if (this is AuthenticationException) {
      return AuthenticationFailure(
        message: (this as AuthenticationException).message,
        stackTrace: (this as AuthenticationException).stackTrace,
        error: (this as AuthenticationException).error,
      );
    } else if (this is AuthorizationException) {
      return AuthorizationFailure(
        message: (this as AuthorizationException).message,
        stackTrace: (this as AuthorizationException).stackTrace,
        error: (this as AuthorizationException).error,
      );
    } else if (this is ValidationException) {
      return ValidationFailure(
        message: (this as ValidationException).message,
        errors: (this as ValidationException).errors,
        stackTrace: (this as ValidationException).stackTrace,
        error: (this as ValidationException).error,
      );
    } else if (this is NotFoundException) {
      return NotFoundFailure(
        message: (this as NotFoundException).message,
        stackTrace: (this as NotFoundException).stackTrace,
        error: (this as NotFoundException).error,
      );
    } else if (this is LocalDataException) {
      return LocalDataFailure(
        message: (this as LocalDataException).message,
        stackTrace: (this as LocalDataException).stackTrace,
        error: (this as LocalDataException).error,
      );
    } else if (this is Failure) {
      return this as Failure;
    } else {
      return ServerFailure(
        message: toString(),
        error: this,
      );
    }
  }
}
