import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/app_exception.dart';
import 'api_interceptor.dart';

class DioClient {
  DioClient(this._dio);

  final Dio _dio;

  static Dio create(ApiInterceptor interceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(interceptor);
    return dio;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _handleDioException(error);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _handleDioException(error);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _handleDioException(error);
    }
  }

  AppException _handleDioException(DioException error) {
    final responseData = error.response?.data;
    String? message;
    if (responseData is Map<String, dynamic>) {
      final nestedError = responseData['error'];
      message = responseData['message'] as String?;
      if (message == null && nestedError is Map<String, dynamic>) {
        message = nestedError['message'] as String?;
      }
    }

    return AppException(
      message: message ?? error.message ?? 'Something went wrong',
      statusCode: error.response?.statusCode,
      details: responseData,
    );
  }
}
