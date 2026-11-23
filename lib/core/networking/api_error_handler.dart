import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  static const String _defaultMessage =
      'Something went wrong, please try again';

  static String getMessage(Object error) {
    if (error is! DioException) {
      debugPrint('Unexpected error: $error');
      return _defaultMessage;
    }

    debugPrint('Network error (${error.type}): ${error.error}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out, please try again';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return 'Could not reach the server, check your internet connection';
      case DioExceptionType.badResponse:
        return _serverMessage(error.response?.data);
      default:
        return _defaultMessage;
    }
  }

  static String _serverMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return _defaultMessage;

    final message = data['message'];
    if (message is String) return message;
    if (message is Map<String, dynamic>) {
      return message.values
          .expand(
            (fieldErrors) => fieldErrors is List ? fieldErrors : [fieldErrors],
          )
          .join('\n');
    }
    return _defaultMessage;
  }
}
