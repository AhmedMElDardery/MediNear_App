import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medinear_app/core/services/local_storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

