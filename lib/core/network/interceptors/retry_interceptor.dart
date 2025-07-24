import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Simple retry for timeout / network errors.
final class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.retries = 2});
  final int retries;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final  count = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if ((count < retries) &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError)) {
      err.requestOptions.extra['retryCount'] = count + 1;
      debugPrint('🔄 Retry ${count + 1} ${err.requestOptions.uri}');
      handler.resolve(await Dio().fetch(err.requestOptions));
    } else {
      handler.next(err);
    }
  }
}