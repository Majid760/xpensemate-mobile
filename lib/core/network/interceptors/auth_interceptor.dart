import 'package:dio/dio.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

/// Uses QueuedInterceptor to avoid race conditions.
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokenStorage, this._refreshToken);
  
  final IStorageService _tokenStorage;
  final Future<String?> Function() _refreshToken;

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
      // Try to refresh the token
      final newToken = await _refreshToken();
      if (newToken == null) return handler.reject(err);
      // Update the token in storage using generic method
      await _tokenStorage.save(StorageKeys.accessTokenKey, newToken);
      // Retry the original request with the new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      handler.resolve(await Dio().fetch(opts));
    } on Exception catch (_) {
      handler.reject(err);
    }
  }
}