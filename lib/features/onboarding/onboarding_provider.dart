import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:medinear_app/core/services/local_storage_service.dart';
import 'package:medinear_app/core/routes/routes.dart';

class OnboardingProvider extends ChangeNotifier {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> finishOnboarding(BuildContext context) async {
    await LocalStorageService.setFirstTimeFalse();
    context.go(AppRoutes.login);
  }
}
