import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/core/services/local_storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/services/token_storage.dart';

class SplashProvider extends ChangeNotifier {
  final TokenStorage storage;

  SplashProvider(this.storage);

  Future<void> checkAppState(BuildContext context) async {
    debugPrint("Checking app state");
    
    // Perform heavy initializations here so the UI can show a loading indicator
    await Future.wait([
      dotenv.load(fileName: ".env"),
      LocalStorageService.init(),
      Firebase.initializeApp(),
    ]);

    bool isFirstTime = LocalStorageService.isFirstTime();
    String? token = await storage.getToken();

    await Future.delayed(const Duration(seconds: 1)); // Give the animations some time to finish smoothly
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
