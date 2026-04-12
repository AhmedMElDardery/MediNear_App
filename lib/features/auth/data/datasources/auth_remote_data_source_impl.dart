import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:medinear_app/features/auth/data/models/user_model.dart';
import 'package:medinear_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter/foundation.dart'; // 🚀 عشان الـ kDebugMode والـ print

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  final String googleApiUrl = 'https://medinear-eg.com/api/auth/google/login';
  final String fbApiUrl = 'https://medinear-eg.com/api/auth/facebook/login';

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) throw Exception('فشل في الحصول على بيانات جوجل');

      final response = await dio.post(
        googleApiUrl,
        data: {'access_token': accessToken},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (kDebugMode) print("📥 Google Login Response: ${response.data}");

      if (response.statusCode == 200 && response.data['status'] == true) {
        return UserModel.fromJson(
          response.data['data']['user'],
          response.data['data']['token'],
        );
      } else {
        throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول من السيرفر.');
      }
    } catch (e) {
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  @override
  Future<UserModel?> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final String accessToken = result.accessToken!.tokenString;

        final response = await dio.post(
          fbApiUrl,
          data: {'access_token': accessToken},
          options: Options(headers: {'Accept': 'application/json'}),
        );

        if (kDebugMode) print("📥 FB Login Response: ${response.data}");

        if (response.statusCode == 200 && response.data['status'] == true) {
          return UserModel.fromJson(
            response.data['data']['user'],
            response.data['data']['token'],
          );
        } else {
          throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول من السيرفر.');
        }
      } else if (result.status == LoginStatus.cancelled) {
        return null;
      } else {
        throw Exception(result.message ?? 'فشل تسجيل الدخول بفيسبوك.');
      }
    } catch (e) {
      await FacebookAuth.instance.logOut();
      rethrow;
    }
  }

  // 🚀 دالة الخروج مع الـ Logs للتأكيد
  @override
  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect(); // بيمسح الأكونت من الذاكرة
        await _googleSignIn.signOut();
        if (kDebugMode) print("🧹 [Remote] Google Account Disconnected & Signed Out");
      }
      await FacebookAuth.instance.logOut();
      if (kDebugMode) print("🧹 [Remote] Facebook Signed Out");
    } catch (e) {
      if (kDebugMode) print("⚠️ Local logout error: $e");
    }
  }
}