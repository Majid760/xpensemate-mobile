// core/network/network_client.dart
import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';

abstract class NetworkClientContracts {
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<Either<Failure, T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<Either<Failure, T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<Either<Failure, T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<Either<Failure, T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    T Function(Map<String, dynamic>)? fromJson,
  });
}