import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/core/services/local_storage_service.dart';
import '../../core/services/token_storage.dart';

class SplashProvider extends ChangeNotifier {
  final TokenStorage storage;

  SplashProvider(this.storage);

  Future<void> checkAppState(BuildContext context) async {
    debugPrint("Checking app state");
    bool isFirstTime = LocalStorageService.isFirstTime();
    String? token = await storage.getToken();

    await Future.delayed(const Duration(seconds: 2));

    //is first
    if (isFirstTime) {
      context.go(AppRoutes.onboarding);
      return;
    }

    // token => home
    if (token != null && token.isNotEmpty) {
      context.go(AppRoutes.home);
      return;
    }

    //not token => login
    context.go(AppRoutes.login);
  }
}
