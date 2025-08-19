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
        },
        (token) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
            logI('AuthInterceptor attached token');
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

      final refreshEither = await _authLocal.getRefreshToken();
      String? refreshToken;
      refreshEither.fold(
        (failure) => logE('getRefreshToken failed: ${failure.message}'),
        (token) => refreshToken = token,
      );
      if (refreshToken == null || refreshToken!.isEmpty) {
        logE('No refresh token available');
        return handler.reject(err);
      }
      
      final refreshDio = Dio();
      try {
        final refreshResponse = await refreshDio.post<dynamic>(
          '${NetworkConfigs.baseUrl}${NetworkConfigs.refreshToken}',
          data: {'refresh': refreshToken},
          options:  Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        
        final responseData =
            refreshResponse.data as Map<String, dynamic>;
        final authToken = AuthTokenModel.fromJson(responseData);
        
        // Store the new tokens
        final storeEither = await _authLocal.storeTokens(authToken);
        storeEither.fold(
          (failure) => logE('storeTokens failed: ${failure.message}'),
          (_) => logI('Tokens refreshed and stored'),
        );
        
        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] =
            'Bearer ${authToken.accessToken}';
        handler.resolve(await Dio().fetch(opts));
      } on DioException catch (refreshError) {
        logE('Refresh token request failed: ${refreshError.message}');
        
        if (refreshError.response?.statusCode == 401) {
          logE('Refresh token expired, clearing tokens');
          await _authLocal.clearTokens();
        }
        
        return handler.reject(err);
      }
    } on Exception catch (e) {
      logE('Error during token refresh: $e');
      handler.reject(err);
    }
  }
}