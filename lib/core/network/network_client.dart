import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/error.dart';
import 'package:xpensemate/core/network/interceptors/auth_interceptor.dart';
import 'package:xpensemate/core/network/interceptors/logging_interceptor.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/auth/data/services/auth_service.dart';

final class NetworkClientImp implements NetworkClient {
  NetworkClientImp({
    required AuthService authService,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: NetworkConfigs.baseUrl,
            connectTimeout: NetworkConfigs.connectTimeout,
            receiveTimeout: NetworkConfigs.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )..interceptors.addAll([
            LoggingInterceptor(),
            AuthInterceptor(authService),
          ]);

  final Dio _dio;

  /* ---------- public contract ---------- */

  @override
  Future<Either<Failure, T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = true,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) =>
      _request(
        () => _dio.get(
          path,
          data: data,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ),
        fromJson,
        isConcurrent: isConcurrent,
      );

  @override
  Future<Either<Failure, T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = true,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) =>
      _request(
        () => _dio.post(
          path,
          data: data,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
        ),
        fromJson,
        isConcurrent: isConcurrent,
      );

  @override
  Future<Either<Failure, T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = true,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) =>
      _request(
        () => _dio.patch(
          path,
          data: data,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
        ),
        fromJson,
        isConcurrent: isConcurrent,
      );

  @override
  Future<Either<Failure, T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = true,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _request(
        () => _dio.delete(
          path,
          data: data,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        ),
        fromJson,
        isConcurrent: isConcurrent,
      );

  @override
  Future<Either<Failure, T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = true,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) =>
      _request(
        () => _dio.put(
          path,
          data: data,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
        fromJson,
        isConcurrent: isConcurrent,
      );

  /* ---------- private helper ---------- */
  Future<Either<Failure, T>> _request<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic>)? fromJson, {
    bool isConcurrent = false,
  }) async {
    try {
      final res = await call();
      final responseData = res.data as Map<String, dynamic>;

      // Parse API response with compute if needed
      final apiResponse = await _parseApiResponse<T>(
        responseData,
        fromJson,
        isConcurrent,
      );

      if (apiResponse.isSuccess) {
        if (fromJson != null && apiResponse.data != null) {
          return Right(apiResponse.data as T);
        }
        if (apiResponse.data != null) {
          return Right(apiResponse.data as T);
        }
        return Right(apiResponse as T);
      } else {
        // Handle business logic errors from API
        final error = _handleApiError(apiResponse);
        ErrorLogger.logNonFatal(error);
        return Left(_mapAppErrorToFailure(error));
      }
    } on DioException catch (e, s) {
      // Convert DioException to AppError
      final appError = ErrorHandler.handleDioError(e, s);
      ErrorLogger.log(appError);
      return Left(_mapAppErrorToFailure(appError));
    } on Exception catch (e, s) {
      // Handle unexpected exceptions
      final appError = ErrorHandler.handleException(e, s);
      ErrorLogger.log(appError);
      return Left(_mapAppErrorToFailure(appError));
    }
  }

  /// Parse API response using compute for heavy parsing
  Future<ApiResponse<T>> _parseApiResponse<T>(
    Map<String, dynamic> responseData,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent,
  ) async {
    // Use compute for concurrent parsing if enabled and fromJson is provided
    if (isConcurrent && fromJson != null) {
      return compute(
        _parseInIsolate<T>,
        _ParseParams<T>(
          responseData: responseData,
          fromJson: fromJson,
        ),
      );
    }

    // Parse on main thread for small responses
    return ApiResponse.fromJson(responseData, fromJson);
  }

  /// Handle API business logic errors
  AppError _handleApiError(ApiResponse<dynamic> response) => switch (response.type.toLowerCase()) {
        'error' => ServerError(
            message: response.message,
            code: 'API_ERROR',
            statusCode: null,
          ),
        'warning' => ValidationError(
            message: response.message,
            code: 'API_WARNING',
            statusCode: null,
          ),
        'info' => ServerError(
            message: response.message,
            code: 'API_INFO',
            statusCode: null,
          ),
        _ => ServerError(
            message: response.message,
            code: 'API_UNKNOWN',
            statusCode: null,
          ),
      };

  /// Map AppError to Failure for backward compatibility
  Failure _mapAppErrorToFailure(AppError error) => switch (error) {
        NetworkError() => NetworkFailure(message: error.displayMessage),
        TimeoutError() => NetworkFailure(message: error.displayMessage),
        AuthError() => ServerFailure(message: error.displayMessage),
        ValidationError() => ServerFailure(message: error.displayMessage),
        FileError() => ServerFailure(message: error.displayMessage),
        ServerError() => ServerFailure(message: error.displayMessage),
        UnknownError() => ServerFailure(message: error.displayMessage),
      };

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}

/* ---------- Isolate Parsing ---------- */

/// Top-level function for isolate parsing
ApiResponse<T> _parseInIsolate<T>(_ParseParams<T> params) => ApiResponse<T>.fromJson(
      params.responseData,
      params.fromJson,
    );

/// Parameters for isolate parsing
class _ParseParams<T> {
  const _ParseParams({
    required this.responseData,
    required this.fromJson,
  });

  final Map<String, dynamic> responseData;
  final T Function(Map<String, dynamic>) fromJson;
}

/* ---------- API Response Model ---------- */

class ApiResponse<T> {
  const ApiResponse({
    required this.type,
    required this.title,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      return ApiResponse<T>(
        type: json['type'] as String? ?? 'unknown',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        data: json['data'] != null && fromJson != null ? fromJson(json['data'] as Map<String, dynamic>) : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  final String type;
  final String title;
  final String message;
  final T? data;

  bool get isSuccess => type.toLowerCase() == 'success';
  bool get isError => type.toLowerCase() == 'error';
  bool get isWarning => type.toLowerCase() == 'warning';
  bool get isInfo => type.toLowerCase() == 'info';
}
