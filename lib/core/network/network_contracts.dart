// core/network/network_contracts.dart
import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class NetworkClient {
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
  });

  Future<Either<Failure, T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
  });

  Future<Either<Failure, T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
  });

  Future<Either<Failure, T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
  });

  Future<Either<Failure, T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    FromJson<T>? fromJson,
    bool isConcurrent = false,
  });
}