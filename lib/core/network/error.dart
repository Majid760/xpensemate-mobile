// lib/core/error/app_error.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

/// Base error class for all application errors
sealed class AppError implements Exception {
  const AppError({
    required this.message,
    required this.type,
    this.code,
    this.statusCode,
    this.stackTrace,
  });

  final String message;
  final ErrorType type;
  final String? code;
  final int? statusCode;
  final StackTrace? stackTrace;

  /// User-friendly message to display
  String get displayMessage => message;

  /// Whether this error should be logged
  bool get shouldLog => type != ErrorType.validation;

  /// Whether to show retry option
  bool get canRetry => type == ErrorType.network || type == ErrorType.timeout;
}

/// Network-related errors
final class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.statusCode,
    super.stackTrace,
  }) : super(type: ErrorType.network);
}

/// Server-related errors (4xx, 5xx)
final class ServerError extends AppError {
  const ServerError({
    required super.message,
    super.code,
    required super.statusCode,
    super.stackTrace,
  }) : super(type: ErrorType.server);
}

/// Authentication/Authorization errors
final class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.statusCode,
    super.stackTrace,
  }) : super(type: ErrorType.auth);
}

/// Validation errors
final class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.code,
    required super.statusCode,
    Map<String, String>? fieldErrors,
    super.stackTrace,
  })  : fieldErrors = fieldErrors ?? const {},
        super(type: ErrorType.validation);

  final Map<String, String> fieldErrors;
}

/// Timeout errors
final class TimeoutError extends AppError {
  const TimeoutError({
    required super.message,
    super.code,
    super.stackTrace,
  }) : super(type: ErrorType.timeout);
}

/// File/Upload errors
final class FileError extends AppError {
  const FileError({
    required super.message,
    super.code,
    super.statusCode,
    super.stackTrace,
  }) : super(type: ErrorType.file);
}

/// Unknown/Unexpected errors
final class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.code,
    super.stackTrace,
  }) : super(type: ErrorType.unknown);
}

/// Error types for categorization
enum ErrorType {
  network,
  server,
  auth,
  validation,
  timeout,
  file,
  unknown;

  String get displayName => switch (this) {
        ErrorType.network => 'Network Error',
        ErrorType.server => 'Server Error',
        ErrorType.auth => 'Authentication Error',
        ErrorType.validation => 'Validation Error',
        ErrorType.timeout => 'Timeout Error',
        ErrorType.file => 'File Error',
        ErrorType.unknown => 'Unexpected Error',
      };
}

// lib/core/error/error_messages.dart

/// Centralized error messages
class ErrorMessages {
  // Network Errors
  static const connectionTimeout = 'Request timed out. Please check your connection and try again.';
  static const receiveTimeout = 'Server took too long to respond. Please try again.';
  static const sendTimeout = 'Failed to send request. Please check your connection.';
  static const noInternet = 'Unable to connect. Please check your internet connection.';
  static const badCertificate = 'Security certificate error. Connection is not secure.';
  static const requestCancelled = 'Request was cancelled.';
  static const badResponse = 'Received invalid response from server. Please try again.';

  // Authentication & Authorization (4xx)
  static const badRequest = 'Invalid request. Please check your input and try again.';
  static const unauthorized = 'Session expired. Please log in again.';
  static const paymentRequired = 'Payment required to access this feature.';
  static const forbidden = "You don't have permission to access this resource.";
  static const notFound = 'The requested resource was not found.';
  static const methodNotAllowed = 'This action is not allowed.';
  static const notAcceptable = 'Request format is not acceptable.';
  static const requestTimeout = 'Request timed out. Please try again.';
  static const conflict = 'This action conflicts with existing data. Please refresh and try again.';
  static const gone = 'This resource is no longer available.';
  static const payloadTooLarge = 'File or data is too large. Please reduce the size and try again.';
  static const unsupportedMediaType = 'Unsupported file type or format.';
  static const unprocessableEntity = 'Unable to process your request. Please verify your input.';
  static const locked = 'This resource is currently locked.';
  static const tooManyRequests = 'Too many requests. Please wait a moment and try again.';
  static const unavailableForLegalReasons = 'Content unavailable for legal reasons.';

  // Server Errors (5xx)
  static const internalServerError = 'Internal server error. Please try again later.';
  static const notImplemented = 'This feature is not implemented yet.';
  static const badGateway = 'Bad gateway. Server is temporarily unavailable.';
  static const serviceUnavailable = 'Service is temporarily unavailable. Please try again later.';
  static const gatewayTimeout = 'Gateway timeout. Server took too long to respond.';
  static const insufficientStorage = 'Server storage is full.';
  static const bandwidthLimitExceeded = 'Bandwidth limit exceeded.';

  // Generic
  static const unknownError = 'An unexpected error occurred. Please try again.';
  static const genericServerError = 'Server is experiencing issues. Please try again later.';
}

// lib/core/error/error_handler.dart

/// Main error handler that converts exceptions to AppError
class ErrorHandler {
  /// Convert DioException to AppError
  static AppError handleDioError(DioException e, [StackTrace? stackTrace]) {
    // Handle Dio exception types
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutError(
          message: ErrorMessages.connectionTimeout,
          code: 'CONNECTION_TIMEOUT',
          stackTrace: stackTrace,
        );

      case DioExceptionType.receiveTimeout:
        return TimeoutError(
          message: ErrorMessages.receiveTimeout,
          code: 'RECEIVE_TIMEOUT',
          stackTrace: stackTrace,
        );

      case DioExceptionType.sendTimeout:
        return TimeoutError(
          message: ErrorMessages.sendTimeout,
          code: 'SEND_TIMEOUT',
          stackTrace: stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkError(
          message: ErrorMessages.noInternet,
          code: 'CONNECTION_ERROR',
          stackTrace: stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkError(
          message: ErrorMessages.badCertificate,
          code: 'BAD_CERTIFICATE',
          stackTrace: stackTrace,
        );

      case DioExceptionType.cancel:
        return NetworkError(
          message: ErrorMessages.requestCancelled,
          code: 'REQUEST_CANCELLED',
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(e.response, stackTrace);

      case DioExceptionType.unknown:
        return UnknownError(
          message: ErrorMessages.unknownError,
          code: 'UNKNOWN',
          stackTrace: stackTrace,
        );
    }
  }

  /// Handle HTTP status code errors
  static AppError _handleHttpError(Response? response, StackTrace? stackTrace) {
    final statusCode = response?.statusCode ?? 0;

    // Try to extract the real message from the backend response body first.
    // Backend returns: { "type": "error", "title": "...", "message": "..." }
    String? serverMessage;
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        serverMessage = data['message']?.toString();
      }
    } on Exception catch (e) {
      AppLogger.e('Error parsing backend response: $e');
    }

    return switch (statusCode) {
      // Client Errors (4xx)
      400 => ValidationError(
          message: serverMessage ?? ErrorMessages.badRequest,
          code: 'BAD_REQUEST',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      401 => AuthError(
          // Use the actual backend message (e.g., "Invalid email or password")
          // instead of the generic "Session expired" whenever possible.
          message: serverMessage ?? ErrorMessages.unauthorized,
          code: 'UNAUTHORIZED',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      402 => ServerError(
          message: serverMessage ?? ErrorMessages.paymentRequired,
          code: 'PAYMENT_REQUIRED',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      403 => AuthError(
          message: serverMessage ?? ErrorMessages.forbidden,
          code: 'FORBIDDEN',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      404 => ServerError(
          message: serverMessage ?? ErrorMessages.notFound,
          code: 'NOT_FOUND',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      405 => ServerError(
          message: serverMessage ?? ErrorMessages.methodNotAllowed,
          code: 'METHOD_NOT_ALLOWED',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      406 => ServerError(
          message: serverMessage ?? ErrorMessages.notAcceptable,
          code: 'NOT_ACCEPTABLE',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      408 => TimeoutError(
          message: serverMessage ?? ErrorMessages.requestTimeout,
          code: 'REQUEST_TIMEOUT',
          stackTrace: stackTrace,
        ),
      409 => ServerError(
          message: serverMessage ?? ErrorMessages.conflict,
          code: 'CONFLICT',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      410 => ServerError(
          message: serverMessage ?? ErrorMessages.gone,
          code: 'GONE',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      413 => FileError(
          message: serverMessage ?? ErrorMessages.payloadTooLarge,
          code: 'PAYLOAD_TOO_LARGE',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      415 => FileError(
          message: serverMessage ?? ErrorMessages.unsupportedMediaType,
          code: 'UNSUPPORTED_MEDIA_TYPE',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      422 => ValidationError(
          message: serverMessage ?? ErrorMessages.unprocessableEntity,
          code: 'UNPROCESSABLE_ENTITY',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      423 => ServerError(
          message: serverMessage ?? ErrorMessages.locked,
          code: 'LOCKED',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      429 => ServerError(
          message: serverMessage ?? ErrorMessages.tooManyRequests,
          code: 'TOO_MANY_REQUESTS',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      451 => ServerError(
          message: serverMessage ?? ErrorMessages.unavailableForLegalReasons,
          code: 'UNAVAILABLE_FOR_LEGAL_REASONS',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),

      // Server Errors (5xx)
      500 => ServerError(
          message: serverMessage ?? ErrorMessages.internalServerError,
          code: 'INTERNAL_SERVER_ERROR',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      501 => ServerError(
          message: serverMessage ?? ErrorMessages.notImplemented,
          code: 'NOT_IMPLEMENTED',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      502 => ServerError(
          message: serverMessage ?? ErrorMessages.badGateway,
          code: 'BAD_GATEWAY',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      503 => ServerError(
          message: serverMessage ?? ErrorMessages.serviceUnavailable,
          code: 'SERVICE_UNAVAILABLE',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      504 => TimeoutError(
          message: serverMessage ?? ErrorMessages.gatewayTimeout,
          code: 'GATEWAY_TIMEOUT',
          stackTrace: stackTrace,
        ),
      507 => ServerError(
          message: serverMessage ?? ErrorMessages.insufficientStorage,
          code: 'INSUFFICIENT_STORAGE',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      509 => ServerError(
          message: serverMessage ?? ErrorMessages.bandwidthLimitExceeded,
          code: 'BANDWIDTH_LIMIT_EXCEEDED',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),

      // Fallback
      _ when statusCode >= 400 && statusCode < 500 => ServerError(
          message: serverMessage ?? ErrorMessages.badRequest,
          code: 'CLIENT_ERROR',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      _ when statusCode >= 500 => ServerError(
          message: serverMessage ?? ErrorMessages.genericServerError,
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          stackTrace: stackTrace,
        ),
      _ => UnknownError(
          message: serverMessage ?? ErrorMessages.unknownError,
          code: 'UNKNOWN_ERROR',
          stackTrace: stackTrace,
        ),
    };
  }

  /// Handle generic exceptions
  static AppError handleException(Object e, [StackTrace? stackTrace]) {
    if (e is DioException) {
      return handleDioError(e, stackTrace);
    }

    if (e is AppError) {
      return e;
    }

    return UnknownError(
      message: e.toString(),
      code: 'UNEXPECTED_ERROR',
      stackTrace: stackTrace,
    );
  }
}

// lib/core/error/error_logger.dart

/// Logger for errors
class ErrorLogger {
  /// Log error to analytics/crashlytics
  static void log(AppError error) {
    if (!error.shouldLog) return;

    // Log to console in debug mode
    if (kDebugMode) {
      print('❌ ${error.type.displayName}: ${error.message}');
      if (error.code != null) print('   Code: ${error.code}');
      if (error.statusCode != null) print('   Status: ${error.statusCode}');
      if (error.stackTrace != null) print('   Stack: ${error.stackTrace}');
    }

    // Send to Crashlytics/Sentry in production
    // FirebaseCrashlytics.instance.recordError(error, error.stackTrace);
    // Sentry.captureException(error, stackTrace: error.stackTrace);
  }

  /// Log non-fatal error
  static void logNonFatal(AppError error) {
    if (kDebugMode) {
      print('⚠️  Non-fatal ${error.type.displayName}: ${error.message}');
    }
    // FirebaseCrashlytics.instance.recordError(error, error.stackTrace, fatal: false);
  }
}
