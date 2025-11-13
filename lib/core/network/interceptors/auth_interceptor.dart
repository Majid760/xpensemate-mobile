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

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      var accessToken = _authService.token;
      logI(
          "this is accesss token before checking => ${accessToken.isNotEmpty ? accessToken.substring(0, 6) : 'empty'}");
      if (accessToken.isEmpty) {
        logI("error access token is empty, fetching from storage");
        scheduleMicrotask(_authService.getAccessToken);
        if (_authService.token.isNotEmpty) {
          accessToken = _authService.token;
        } else {
          AppLogger.e('getAccessToken from storageg failed');
        }
      }
      options.headers['Authorization'] = 'Bearer $accessToken';
      AppLogger.i(
        'AuthInterceptor attached token: ${accessToken.substring(0, (accessToken.length > 10 ? 10 : accessToken.length))}...',
      );
      handler.next(options);
    } on Exception catch (e) {
      // proceed without token
      AppLogger.e('error while getting token=> $e');
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
      AppLogger.i(
        'Token expired or invalid (status ${err.response?.statusCode}), attempting to refresh...',
      );
      // Get the refresh token
      final refreshToken = _authService.userRefreshToken;
      logI("refreshed token in storage => ${refreshToken.isNotEmpty ? refreshToken.substring(0, 6) : 'empty'}");

      if (refreshToken.isEmpty) AppLogger.e('No refresh token available');

      // Attempt to refresh the token
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
          // Save the new token using AuthService
          scheduleMicrotask(() => _authService.saveTokenToStorage(newToken));
          logI('Token refreshed successfully');
          // Update the request with the new token and retry
          final newOptions = err.requestOptions.copyWith();
          newOptions.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
          return handler.resolve(await dio.fetch(newOptions));
        } else {
          logI('Failed to refresh token: ${response.statusMessage} and status => ${response.statusCode}');
        }
      } on Exception catch (refreshError) {
        AppLogger.e('Error refreshing token: $refreshError');
      }
      return handler.next(err);
    } on Exception catch (e) {
      AppLogger.e('Error in auth interceptor: $e');
      handler.next(err);
    }
  }
}
