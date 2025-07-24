// core/network/dio_network_client.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/interceptors/auth_interceptor.dart' ;
import 'package:xpensemate/core/network/interceptors/logging_interceptor.dart';
import 'package:xpensemate/core/network/interceptors/retry_interceptor.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';

final class DioNetworkClient implements NetworkClientContracts {
  DioNetworkClient({
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
            RetryInterceptor(retries: NetworkConfigs.maxRetries),
            AuthInterceptor(token, refreshToken),
          ]);

  final Dio _dio;

  /* ---------- public contract ---------- */

  @override
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  }) =>
      _request(() => _dio.get(path, queryParameters: query), fromJson);

  @override
  Future<Either<Failure, T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  }) =>
      _request(
          () => _dio.post(path, data: body, queryParameters: query), fromJson,);

  @override
  Future<Either<Failure, T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  }) =>
      _request(
          () => _dio.patch(path, data: body, queryParameters: query), fromJson,);

  @override
  Future<Either<Failure, T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  }) =>
      _request(() => _dio.delete(path, data: body, queryParameters: query),
          fromJson,);

  @override
  Future<Either<Failure, T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
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
      if (fromJson != null) {
        return Right(fromJson(res.data as Map<String, dynamic>));
      }
      return Right(res.data as T);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          const NetworkFailure(message: 'Connection timeout'),
        DioExceptionType.connectionError =>
          const NetworkFailure(message: 'No internet'),
        _ => switch (e.response?.statusCode) {
            401 => const ServerFailure(message: 'Unauthorized'),
            402 => const ServerFailure(message: 'Subscription required'),
            404 => const ServerFailure(message: 'Not found'),
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
