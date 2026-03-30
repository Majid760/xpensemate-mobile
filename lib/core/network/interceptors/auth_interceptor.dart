import 'dart:async';

import 'package:dio/dio.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/services/auth_service.dart';

/// Uses QueuedInterceptor to avoid race conditions.
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._authService);

  final AuthService _authService;

  /// Public endpoints that should NOT have an Authorization header.
  static const _publicPaths = <String>[
    NetworkConfigs.login,
    NetworkConfigs.register,
    NetworkConfigs.forgotPassword,
    NetworkConfigs.resetPassword,
    NetworkConfigs.sendVerificationEmail,
    NetworkConfigs.loginWithGoogle,
  ];

  /// Returns true if [path] is a public endpoint that doesn't require auth.
  bool _isPublicEndpoint(String path) =>
      _publicPaths.any((p) => path.contains(p));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip auth header for public endpoints (login, register, etc.)
      if (_isPublicEndpoint(options.path)) {
        print("this is public path => ${options.path}");
        logI('AuthInterceptor: skipping auth header for public endpoint ${options.path}');
        return handler.next(options);
      }

      var accessToken = _authService.token;
      logI(
        "this is accesss token before checking => ${accessToken.isNotEmpty ? accessToken.substring(0, 6) : 'empty'}",
      );
      if (accessToken.isEmpty) {
        logI("error access token is empty, fetching from storage");
        // Await the token retrieval directly
        final token = await _authService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          accessToken = token;
          logI("access token IS NOW NOT empty, fetched from storage");
        } else {
          logE('getAccessToken from storage failed');
        }
      }
      options.headers['Authorization'] = 'Bearer $accessToken';
      logI(
        'AuthInterceptor attached token: ${accessToken.substring(0, (accessToken.length > 10 ? 10 : accessToken.length))}...',
      );
      handler.next(options);
    } on Exception catch (e) {
      // proceed without token
      logE('error while getting token=> $e');
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // Handle 401 and 403 errors
      if (err.response?.statusCode != 401 && err.response?.statusCode != 403) {
        return handler.next(err);
      }

      // Don't attempt token refresh for public endpoints — they don't use auth
      if (_isPublicEndpoint(err.requestOptions.path)) {
        return handler.next(err);
      }

      logI('Token expired or invalid (status ${err.response?.statusCode}), analyzing error...');
      
      final usedTokenStr = err.requestOptions.headers['Authorization']?.toString() ?? '';
      final usedToken = usedTokenStr.startsWith('Bearer ') ? usedTokenStr.substring(7) : usedTokenStr;
      final currentToken = _authService.token;

      // 1. Concurrent refresh protection 
      // If the token used in the failed request is DIFFERENT from the current service token,
      // it means a previous request in the queue already refreshed it! We just retry.
      if (usedToken != currentToken && currentToken.isNotEmpty) {
        logI('Token was already refreshed by another concurrent request. Retrying directly...');
        final newOptions = err.requestOptions.copyWith();
        newOptions.headers['Authorization'] = 'Bearer $currentToken';
        final retryDio = Dio(BaseOptions(baseUrl: NetworkConfigs.baseUrl));
        return handler.resolve(await retryDio.fetch(newOptions));
      }

      // Get the refresh token
      final refreshToken = _authService.userRefreshToken;
      logI("Refresh token in storage => ${refreshToken.isNotEmpty ? refreshToken.substring(0, 6) : 'empty'}");

      // Stop immediately if completely logged out/no refresh token to prevent broken calls
      if (refreshToken.isEmpty) {
        logE('No refresh token available - passing error down.');
        return handler.next(err);
      }

      // Attempt to refresh the token
      logI('Attempting to refresh token from network...');
      try {
        final dio = Dio(BaseOptions(baseUrl: NetworkConfigs.baseUrl));
        final response = await dio.post<dynamic>(
          NetworkConfigs.refreshToken,
          data: {'refreshToken': refreshToken},
        );
        logI('RefreshToken response => : ${response.statusMessage} and status => ${response.statusCode}');

        if (response.statusCode == 200 && response.data != null) {
          // Parse the new token
          final newToken = AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
          
          // CRITICAL: Await this synchronously so subsequent queued errors see the new token memory
          await _authService.saveTokenToStorage(newToken);
          logI('Token refreshed successfully');
          
          // Update the request with the new token and retry
          final newOptions = err.requestOptions.copyWith();
          newOptions.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
          return handler.resolve(await dio.fetch(newOptions));
        } else {
          logE('Failed to refresh token: ${response.statusMessage} and status => ${response.statusCode}');
        }
      } on Exception catch (refreshError) {
        AppLogger.e('Error calling refresh token API: $refreshError');
      }
      return handler.next(err);
    } on Exception catch (e) {
      AppLogger.e('Error in auth interceptor: $e');
      handler.next(err);
    }
  }
}
