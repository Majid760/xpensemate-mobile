import 'package:dio/dio.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';

/// Uses QueuedInterceptor to avoid race conditions.
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokenStorage);
  
  final IStorageService _tokenStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Get the current access token from storage using generic method
      final token = await _tokenStorage.get(StorageKeys.accessTokenKey);
      
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } on Exception catch (e) {
      // If there's an error getting the token, proceed without it,
      logE("error while getting token=> $e");
      handler.next(options);
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    
    try {
      logI("Token expired, attempting to refresh...");
      
      // Get refresh token from storage
      final refreshToken = await _tokenStorage.get(StorageKeys.refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        logE("No refresh token available");
        return handler.reject(err);
      }
      
      // Create a new Dio instance for refresh token request
      final refreshDio = Dio();
      
      try {
        // Call refresh token endpoint
        final refreshResponse = await refreshDio.post<dynamic>(
          '${NetworkConfigs.baseUrl}${NetworkConfigs.refreshToken}',
          data: {'refresh': refreshToken},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        
        // Parse the response
        final responseData = refreshResponse.data as Map<String, dynamic>;
        final authToken = AuthTokenModel.fromJson(responseData);
        
        // Store the new tokens
        await _tokenStorage.save(StorageKeys.accessTokenKey, authToken.accessToken);
        if (authToken.refreshToken != null) {
          await _tokenStorage.save(StorageKeys.refreshTokenKey, authToken.refreshToken!);
        }
        
        logI("Token refreshed successfully, retrying request");
        
        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${authToken.accessToken}';
        handler.resolve(await Dio().fetch(opts));
      } on DioException catch (refreshError) {
        logE("Refresh token request failed: ${refreshError.message}");
        
        // If refresh token is also expired, clear tokens and reject
        if (refreshError.response?.statusCode == 401) {
          logE("Refresh token expired, clearing tokens");
          await _tokenStorage.remove(StorageKeys.accessTokenKey);
          await _tokenStorage.remove(StorageKeys.refreshTokenKey);
        }
        
        return handler.reject(err);
      }
    } on Exception catch (e) {
      logE("Error during token refresh: $e");
      handler.reject(err);
    }
  }
}