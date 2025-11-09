import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Pretty logger.
final class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 ${options.method} ${options.uri}');
    final authHeader = options.headers['Authorization'];
    if (authHeader != null) {
      debugPrint('🔑 Authorization header present');
    } else {
      debugPrint('🔒 No Authorization header on request');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ${err.response?.statusCode} ${err.requestOptions.uri}');
    super.onError(err, handler);
  }
}
