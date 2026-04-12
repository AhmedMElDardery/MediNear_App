import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medinear_app/core/provider/navigation_provider.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/core/services/user_storage.dart';
import 'package:medinear_app/features/auth/domain/entities/user_entity.dart';
import 'package:medinear_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:medinear_app/core/errors/api_error_handler.dart';
import 'package:medinear_app/core/messages/app_success_messages.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final UserStorage userStorage;

  AuthProvider(this.repository, this.userStorage);

  bool isLoading = false;
  UserEntity? user;
  String? errorMessage;
  String? successMessage;

  UserEntity? get currentUser => user;

  /// يتم استدعاؤها مرة واحدة عند فتح التطبيق لتحميل بيانات المستخدم المحفوظة
  Future<void> loadCachedUser() async {
    user = await userStorage.loadUser();
    notifyListeners();
  }

  Future<bool> loginWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();

      user = await repository.loginWithGoogle();

      if (user != null) {
        successMessage = AppSuccessMessages.login;
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = ApiErrorHandler.getMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithFacebook() async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();

      user = await repository.loginWithFacebook();

      if (user != null) {
        successMessage = AppSuccessMessages.login;
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = ApiErrorHandler.getMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.logout();

      if (context.mounted) {
        Provider.of<NavigationProvider>(context, listen: false).changeIndex(0);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      errorMessage = "حدث خطأ أثناء تسجيل الخروج";
    } finally {
      isLoading = false;
      user = null;
      notifyListeners();
    }
  }
}