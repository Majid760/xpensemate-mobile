// core/network/network_contracts.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:xpensemate/core/error/failures.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class NetworkClient {
  Future<Either<Failure, T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  });

  Future<Either<Failure, T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });

  Future<Either<Failure, T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });

  Future<Either<Failure, T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });

  Future<Either<Failure, T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
    Options? options,
    CancelToken? cancelToken,
  });
}
