import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      // 🚀 لغينا قراءة رسائل السيرفر العربي، وهنعتمد على الإنجليزي بتاعنا بس
      /*
      if (error.response != null && error.response?.data != null) {
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        } else if (data is Map<String, dynamic> && data.containsKey('error')) {
          return data['error'];
        }
      }
      */

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timeout. Please check your internet.";
        case DioExceptionType.sendTimeout:
          return "Send timeout. Please try again later.";
        case DioExceptionType.receiveTimeout:
          return "Receive timeout. Server is taking too long to respond.";
        case DioExceptionType.badCertificate:
          return "Secure connection failed. Bad certificate.";
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 400:
              return "Bad request. Please check your inputs.";
            case 401:
              return "Unauthorized. Incorrect email or password.";
            case 403:
              return "Forbidden. Your account has been temporarily suspended.";
            case 404:
              return "Not found. The requested data does not exist.";
            case 408:
              return "Request timeout. Please try again.";
            case 409:
              return "Conflict. This email or data already exists.";
            case 422:
              return "Validation error. Please check the entered data.";
            case 500:
              return "Internal server error. Our team is working on it.";
            case 502:
              return "Bad gateway. Server is currently down.";
            case 503:
              return "Service unavailable. Please try again later.";
            default:
              return "Received invalid status code: ${error.response?.statusCode}";
          }
        case DioExceptionType.cancel:
          return "Request was cancelled by the user.";
        case DioExceptionType.connectionError:
          return "No Internet Connection. Please connect to WiFi or Mobile Data.";
        case DioExceptionType.unknown:
          return "Unexpected error occurred. Please check your connection and try again.";
      }
    } else {
      return "An unexpected application error occurred.";
    }
  }
}
