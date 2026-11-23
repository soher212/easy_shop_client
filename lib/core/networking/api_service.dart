import 'package:dio/dio.dart';
import 'package:easy_shop_client/core/cache/cache_const.dart';
import 'package:easy_shop_client/core/cache/cache_helper.dart';
import 'package:easy_shop_client/core/networking/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio dio;

  ApiService(this.dio) {
    dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {
        'Accept': 'application/json',
        'x-api-key': ApiConstants.apiKey,
      };
    dio.interceptors.add(InterceptorsWrapper(onRequest: _addToken));
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          compact: false,
          maxWidth: 90,
        ),
      );
    }
  }

  Future<void> _addToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await CacheHelper.getSecureData(
      key: CacheConstants.userToken,
    );
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? query}) {
    return dio.get(endpoint, queryParameters: query);
  }

  Future<Response> post(String endpoint, {Object? data}) {
    return dio.post(endpoint, data: data);
  }

  Future<Response> put(String endpoint, {Object? data}) {
    return dio.put(endpoint, data: data);
  }

  Future<Response> delete(String endpoint, {Object? data}) {
    return dio.delete(endpoint, data: data);
  }
}
