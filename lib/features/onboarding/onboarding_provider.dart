
import 'package:flutter/material.dart';
import 'package:medinear_app/core/services/local_storage_service.dart';
import 'package:medinear_app/core/routes/routes.dart';

class OnboardingProvider extends ChangeNotifier {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index ;
    notifyListeners();
  }

  Future<void> finishOnboarding(BuildContext context) async {
    await LocalStorageService.setFirstTimeFalse();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}