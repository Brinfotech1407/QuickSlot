import 'package:dio/dio.dart';

import '../storage/local_storage_service.dart';
import '../utils/app_logger.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._localStorageService);

  final LocalStorageService _localStorageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _localStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final userId =
        _localStorageService.getInt(LocalStorageService.selectedUserIdKey);
    if (userId != null) {
      options.headers['X-User-Id'] = userId.toString();
    }

    AppLogger.log('REQUEST[${options.method}] => ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.log(
      'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.log(
      'ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}',
    );

    if (err.response?.statusCode == 401) {
      // TODO: Add token refresh or logout handling when authentication is added.
    }

    handler.next(err);
  }
}
