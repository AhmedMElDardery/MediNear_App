import 'package:medinear_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> loginWithGoogle();
  // 🚀 السطر ده هو اللي كان ناقص وموقف الدنيا
  Future<UserModel?> loginWithFacebook();
  
  // 🚀 دالة الخروج (جديدة)
  Future<void> logout();
}