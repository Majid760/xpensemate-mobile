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
          AppLogger.e('getAccessToken failed: ${failure.message}');
          AppLogger.e('Access token failure details: ${failure.error}');
        },
        (token) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            AppLogger.i(
              'AuthInterceptor attached token: ${token.substring(0, 10)}...',
            );
            AppLogger.i('c ${token.substring(0, 10)}...');
          } else {
            AppLogger.e('Access token is null or empty');
          }
        },
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
    if (err.response?.statusCode != 401) return handler.next(err);

    try {
      AppLogger.i('Token expired, attempting to refresh...');

      final refreshEither = await _authLocal.getRefreshToken();
      String? refreshToken;
      refreshEither.fold(
        (failure) {
          AppLogger.e('getRefreshToken failed: ${failure.message}');
          AppLogger.e('getRefreshToken failed: ${failure.message}');
          AppLogger.e('Refresh token failure details: ${failure.error}');
        },
        (token) {
          refreshToken = token;
          if (token != null && token.isNotEmpty) {
            AppLogger.i(
              'Retrieved refresh token: ${token.substring(0, 10)}...',
            );
          } else {
            AppLogger.i('Refresh token is null or empty');
          }
        },
      );
      if (refreshToken == null || refreshToken!.isEmpty) {
        AppLogger.e('No refresh token available');
        return handler.reject(err);
      }

      final refreshDio = Dio();
      try {
        final refreshResponse = await refreshDio.post<dynamic>(
          '${NetworkConfigs.baseUrl}${NetworkConfigs.refreshToken}',
          data: {'token': refreshToken},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
         AppLogger.i(
          'refreshResponse of refreshtok api call ${refreshResponse}',
        );
        final responseData = refreshResponse.data as Map<String, dynamic>;
       
        final authToken = AuthTokenModel.fromJson(responseData);

        // Store the new tokens
        AppLogger.i(
          'Storing refreshed tokens - Access: ${authToken.accessToken.substring(0, 10)}..., Refresh: ${authToken.refreshToken?.substring(0, 10) ?? 'null'}...',
        );
        final storeEither = await _authLocal.storeTokens(authToken);
        storeEither.fold(
          (failure) {
            AppLogger.e('storeTokens failed: ${failure.message}');
            AppLogger.e('Store tokens error details: ${failure.error}');
          },
          (_) => logI('Tokens refreshed and stored successfully'),
        );

        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${authToken.accessToken}';
        handler.resolve(await Dio().fetch(opts));
      } on DioException catch (refreshError) {
        AppLogger.e('Refresh token request failed: ${refreshError.message}');
        AppLogger.e(
          'Refresh error status code: ${refreshError.response?.statusCode}',
        );

        // Only clear tokens if refresh token is actually invalid (401)
        // Don't clear tokens for network errors, timeouts, etc.
        if (refreshError.response?.statusCode == 401) {
          AppLogger.e('Refresh token expired, clearing all tokens');
          await _authLocal.clearTokens();
        } else {
          AppLogger.e(
            'Refresh failed due to network/other error, keeping existing tokens',
          );
        }

        return handler.reject(err);
      }
    } on Exception catch (e) {
      AppLogger.e('Error during token refresh: $e');
      handler.reject(err);
    }
  }
}
