/// Base class for all application exceptions
abstract class AppException implements Exception {

  const AppException({
    required this.message,
    this.stackTrace,
    this.error,
  });
  final String message;
  final StackTrace? stackTrace;
  final dynamic error;

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when there's a failure with the server
class ServerException extends AppException {

  const ServerException({
    required super.message,
     this.statusCode,
    super.stackTrace,
    super.error,
  });
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.stackTrace,
    super.error,
  });
}

/// Exception thrown when there's a timeout
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.stackTrace,
    super.error,
  });
}

/// Exception thrown when there's a failure with local data
class LocalDataException extends AppException {
  const LocalDataException({
    required super.message,
    super.stackTrace,
    super.error,
  });
}

/// Exception thrown when there's a failure with authentication
class AuthenticationException extends AppException {
  const AuthenticationException({
    super.message = 'Authentication failed',
    super.stackTrace,
    super.error,
  });
}

/// Exception thrown when there's a failure with authorization
class AuthorizationException extends AppException {
  const AuthorizationException({
    super.message = 'Not authorized',
    super.stackTrace,
    super.error,
  });
}

/// Exception thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.stackTrace,
    super.error,
  });
}

/// Exception thrown when there's a validation error
class ValidationException extends AppException {

  const ValidationException({
    super.message = 'Validation failed',
    this.errors,
    super.stackTrace,
    super.error,
  });
  final Map<String, List<String>>? errors;

  @override
  String toString() => 'ValidationException: $message${errors != null ? '\nErrors: $errors' : ''}';
}
