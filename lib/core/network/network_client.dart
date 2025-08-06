// core/network/dio_network_client.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/interceptors/auth_interceptor.dart' ;
import 'package:xpensemate/core/network/interceptors/logging_interceptor.dart';
// import 'package:xpensemate/core/network/interceptors/retry_interceptor.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/core/utils/app_logger.dart';



final class NetworkClientImp implements NetworkClient{
  NetworkClientImp({
    required String token,
    required Future<String?> Function() refreshToken,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: NetworkConfigs.baseUrl,
            connectTimeout: NetworkConfigs.connectTimeout,
            receiveTimeout: NetworkConfigs.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        )..interceptors.addAll([
            LoggingInterceptor(),
            // RetryInterceptor(retries: NetworkConfigs.maxRetries),
            AuthInterceptor(token, refreshToken),
          ]);

  final Dio _dio;

  /* ---------- public contract ---------- */

  @override
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = false,
  }) =>
      _request(() => _dio.get(path, queryParameters: query), fromJson);

  @override
  Future<Either<Failure, T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = false,
  }) =>
      _request(
          () => _dio.post(path, data: body, queryParameters: query), fromJson,);

  @override
  Future<Either<Failure, T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = false,
  }) =>
      _request(
          () => _dio.patch(path, data: body, queryParameters: query), fromJson,);

  @override
  Future<Either<Failure, T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = false,
  }) =>
      _request(() => _dio.delete(path, data: body, queryParameters: query),
          fromJson,);

  @override
  Future<Either<Failure, T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
    bool isConcurrent = false,
  }) =>
      _request(
          () => _dio.put(path, data: body, queryParameters: query), fromJson,);

  /* ---------- private helper ---------- */
  Future<Either<Failure, T>> _request<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    try {
      final res = await call();
      logI("res: ${res.data}");
      final responseData = res.data as Map<String, dynamic>;

      logI("responseData: $responseData");
      // Handle standardized API response
      final apiResponse = ApiResponse.fromJson(responseData, fromJson);
            logI("api error: ${apiResponse.message}");

      if (apiResponse.isSuccess) {
        // If fromJson is provided, return the parsed data
        if (fromJson != null && apiResponse.data != null) {
          return Right(apiResponse.data as T);
        }
        // If no fromJson but we have data, return the raw data
        if (apiResponse.data != null) {
          return Right(apiResponse.data as T);
        }
        // For void operations, return the response itself
        return Right(apiResponse as T);
      } else {
        // Handle error responses
        return Left(_handleApiError(apiResponse));
      }
    } on DioException catch (e) {
      logI("dio error: ${e.response?.data}");
      
      // Try to parse structured error response first
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final responseData = e.response!.data as Map<String, dynamic>;
          final apiResponse = ApiResponse<dynamic>.fromJson(responseData, null);
          
          // If we successfully parsed an API response, use it
          if (apiResponse.message.isNotEmpty) {
            return Left(_handleApiError(apiResponse));
          }
        } on Exception catch (parseError) {
          // If parsing fails, fall back to status code mapping
          logI("Failed to parse error response: $parseError");
        }
      }
      
      // Fall back to status code mapping
      return Left(_mapDioError(e));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Handle API error responses
  Failure _handleApiError(ApiResponse<dynamic> response) {
    switch (response.type) {
      case 'error':
        return ServerFailure(message: response.message);
      case 'warning':
        return ServerFailure(message: response.message);
      case 'info':
        return ServerFailure(message: response.message);
      default:
        return ServerFailure(message: response.message);
    }
  }

  Failure _mapDioError(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          const NetworkFailure(message: 'Connection timeout'),
        DioExceptionType.connectionError =>
          const NetworkFailure(message: 'No internet or connection error'),
        _ => switch (e.response?.statusCode) {
            401 => const ServerFailure(message: 'Unauthorized'),
            402 => const ServerFailure(message: 'Subscription required'),
            404 => const ServerFailure(message: 'Not found! Please check your request'),
            403 => const ServerFailure(message: 'Forbidden'),
            400 => const ServerFailure(message: 'Bad request'),
            409 => const ServerFailure(message: 'Conflict'),
            422 => const ServerFailure(message: 'Unprocessable entity'),
            429 => const ServerFailure(message: 'Too many requests'),
            _ when (e.response?.statusCode ?? 0) >= 500 =>
              const ServerFailure(message: 'Server error'),
            _ => ServerFailure(
                message: e.response?.data?.toString() ?? 'Unknown error',
              ),
          },
      };

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}





/// Standard API response model
class ApiResponse<T> {
  const ApiResponse({
    required this.type,
    required this.title,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson) => ApiResponse<T>(
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJson != null 
          ? fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );

  final String type;
  final String title;
  final String message;
  final T? data;

  bool get isSuccess => type.toLowerCase() == 'success';
  bool get isError => type.toLowerCase() == 'error';
  bool get isWarning => type.toLowerCase() == 'warning';
  bool get isInfo => type.toLowerCase() == 'info';
}