import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; 
import '../models/user_model.dart';
import 'package:medinear_app/core/services/token_storage.dart';

class ProfileRemoteDataSource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://medinear-eg.com/api',
      headers: {
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10), 
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 1️⃣ جلب بيانات المستخدم
  Future<UserModel> getUserProfile() async {
    try {
      String? token = await TokenStorage().getToken();

      final response = await _dio.get(
        '/profile',
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final decodedData = response.data;
        final userData = decodedData.containsKey('data')
            ? decodedData['data']
            : (decodedData.containsKey('user') ? decodedData['user'] : decodedData);

        return UserModel.fromJson(userData);
      } else {
        throw Exception('Failed to load profile. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // 2️⃣ تحديث البيانات النصية (الاسم والرقم)
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      String? token = await TokenStorage().getToken();

      if (kDebugMode) print("📤 Data sent to update: $userData");

      final response = await _dio.post(
        '/profile/update', 
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
        data: userData, 
      );

      if (kDebugMode) print("📥 Update Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'فشل تحديث البيانات من السيرفر');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e)); // 🚀 بنستخدم الدالة الذكية اللي تحت
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // 3️⃣ رفع الصورة للسيرفر
  Future<bool> updateProfileImage(File imageFile) async {
    try {
      String? token = await TokenStorage().getToken();

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      if (kDebugMode) print("📤 Uploading Image: $fileName");

      final response = await _dio.post(
        '/profile/update', 
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
        data: formData,
      );

      if (kDebugMode) print("📥 Image Upload Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'فشل رفع الصورة للسيرفر');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e)); // 🚀 بنستخدم الدالة الذكية اللي تحت
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // 🚀 دالة ذكية مخصصة لاستخراج رسالة الـ Validation بتاعة لارافل
  String _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return "السيرفر لا يستجيب، يرجى المحاولة لاحقاً.";
    } 
    
    if (e.response != null && e.response?.data is Map) {
      final responseData = e.response!.data;
      
      // 1. ندور جوه الـ 'errors' الأول (لو موجودة)
      if (responseData['errors'] != null && responseData['errors'] is Map) {
        final Map errors = responseData['errors'];
        if (errors.isNotEmpty) {
          // هنجيب أول رسالة من أول إيرور (مثلاً بتاعة الصورة أو الرقم)
          return errors.values.first[0].toString();
        }
      }
      
      // 2. لو مفيش 'errors'، نجيب الـ 'message' العامة
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }
      
      return 'خطأ من السيرفر: ${e.response?.statusCode}';
    } 
    
    return 'مشكلة في الاتصال بالإنترنت.';
  }
}