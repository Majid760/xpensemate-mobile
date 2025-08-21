import 'package:dio/dio.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_local_storage.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';

/// Uses QueuedInterceptor to avoid race conditions.
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._authLocal);
  
  final AuthLocalDataSource _authLocal;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final tokenEither = await _authLocal.getAccessToken();
      tokenEither.fold(
        (failure) {
          // proceed without token
          logE('getAccessToken failed: ${failure.message}');
          logE('Access token failure details: ${failure.error}');
        },
        (token) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            logI('AuthInterceptor attached token: ${token.substring(0, 10)}...');
          } else {
            logE('Access token is null or empty');
          }
        },
      );
      handler.next(options);
    } on Exception catch (e) {
      // proceed without token
      logE('error while getting token=> $e');
      handler.next(options);
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    
    try {
      logI('Token expired, attempting to refresh...');

      logI('Attempting to get refresh token...');
      final refreshEither = await _authLocal.getRefreshToken();
      String? refreshToken;
      refreshEither.fold(
        (failure) {
          logE('getRefreshToken failed: ${failure.message}');
          logE('Refresh token failure details: ${failure.error}');
          logE('Refresh token failure stack trace: ${failure.stackTrace}');
        },
        (token) {
          refreshToken = token;
          if (token != null && token.isNotEmpty) {
            logI('Retrieved refresh token: ${token.substring(0, 10)}...');
          } else {
            logE('Refresh token is null or empty');
          }
        },
      );
      if (refreshToken == null || refreshToken!.isEmpty) {
        logE('No refresh token available');
        return handler.reject(err);
      }
      
      final refreshDio = Dio();
      try {
        final refreshResponse = await refreshDio.post<dynamic>(
          '${NetworkConfigs.baseUrl}${NetworkConfigs.refreshToken}',
          data: {'token': refreshToken},
          options:  Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        
        final responseData =
            refreshResponse.data as Map<String, dynamic>;
            print('refreshResponse of refreshtok api call ${refreshResponse.data}');
        final authToken = AuthTokenModel.fromJson(responseData);
        
        // Store the new tokens
        logI('Storing refreshed tokens - Access: ${authToken.accessToken.substring(0, 10)}..., Refresh: ${authToken.refreshToken?.substring(0, 10) ?? 'null'}...');
        final storeEither = await _authLocal.storeTokens(authToken);
        storeEither.fold(
          (failure) {
            logE('storeTokens failed: ${failure.message}');
            logE('Store tokens error details: ${failure.error}');
          },
          (_) => logI('Tokens refreshed and stored successfully'),
        );
        
        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] =
            'Bearer ${authToken.accessToken}';
        handler.resolve(await Dio().fetch(opts));
      } on DioException catch (refreshError) {
        logE('Refresh token request failed: ${refreshError.message}');
        logE('Refresh error status code: ${refreshError.response?.statusCode}');
        
        // Only clear tokens if refresh token is actually invalid (401)
        // Don't clear tokens for network errors, timeouts, etc.
        if (refreshError.response?.statusCode == 401) {
          logE('Refresh token expired, clearing all tokens');
          await _authLocal.clearTokens();
        } else {
          logE('Refresh failed due to network/other error, keeping existing tokens');
        }
        
        return handler.reject(err);
      }
    } on Exception catch (e) {
      logE('Error during token refresh: $e');
      handler.reject(err);
    }
  }
}