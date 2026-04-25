import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> loginWithGoogle();
  // 🚀 إضافة الفيسبوك لطبقة الـ Domain
  Future<UserEntity?> loginWithFacebook();

  // 🚀 إضافة الخروج (جديدة)
  Future<void> logout();
}
