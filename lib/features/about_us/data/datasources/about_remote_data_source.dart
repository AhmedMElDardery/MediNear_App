import 'package:flutter/material.dart';
import '../models/support_model.dart';

class AboutRemoteDataSource {
  Future<List<SupportModel>> getSupportOptions() async {
    await Future.delayed(const Duration(milliseconds: 500)); // محاكاة تحميل
    return [
      SupportModel(
          title: "Help Center & FAQ", icon: Icons.headset_mic_outlined),
      SupportModel(title: "Chat with Support", icon: Icons.chat_bubble_outline),
      SupportModel(
          title: "Email Policy",
          icon: Icons.email_outlined,
          trailingIcon: Icons.copy_outlined),
      SupportModel(
          title: "Call Us",
          icon: Icons.phone,
          trailingIcon: Icons.copy_outlined),
    ];
  }

  Future<String> getAppVersion() async {
    return "1.2.3"; // نسخة التطبيق
  }
}
