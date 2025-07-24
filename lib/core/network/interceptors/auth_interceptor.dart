import 'package:dio/dio.dart';


/// Uses QueuedInterceptor to avoid race conditions.
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._token, this._refreshToken);
  String _token;
  final Future<String?> Function() _refreshToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $_token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    try {
      final newToken = await _refreshToken();
      if (newToken == null) return handler.reject(err);

      _token = newToken;
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $_token';
      handler.resolve(await Dio().fetch(opts));
    } on Exception catch (_) {
      handler.reject(err);
    }
  }
}