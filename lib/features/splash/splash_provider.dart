

import 'package:flutter/material.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/core/services/local_storage_service.dart';
import '../../core/services/token_storage.dart';

class SplashProvider extends ChangeNotifier {
  final TokenStorage storage;

  SplashProvider(this.storage);

  Future<void> checkAppState(BuildContext context) async {
    print("Checking app state");
    bool isFirstTime = LocalStorageService.isFirstTime();
    String? token = await storage.getToken(); 

    await Future.delayed(const Duration(seconds: 2));

    //is first  
    if (isFirstTime  ){
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // token => home
    if (token != null && token.isNotEmpty){
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    
    //not token => login
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  
}
