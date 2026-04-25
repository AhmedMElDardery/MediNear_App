import 'package:dio/dio.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import 'package:medinear_app/core/router/app_router.dart';
import 'package:medinear_app/core/routes/routes.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: "https://medinear-eg.com/api",
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    // 🚀 1. Interceptor لسحب التوكن وإضافته أوتوماتيك لأي ريكويست
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // نستخدم الكلاس بتاعك لسحب التوكن المتشفر
        final tokenStorage = TokenStorage();
        final token = await tokenStorage.getToken();

        // لو التوكن موجود، بنحطه في الهيدر بتاع الطلب
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired or invalid
          final tokenStorage = TokenStorage();
          await tokenStorage.clear();
          
          // Force navigate to login screen
          appRouter.go(AppRoutes.login);
        }
        return handler.next(e);
      },
    ));

    // 🚀 2. Interceptor الطباعة في الـ Debug Console
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true, // عشان تشوف التوكن وهو مبعوت بعينك
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }
}
