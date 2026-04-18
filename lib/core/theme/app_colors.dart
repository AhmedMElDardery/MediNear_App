import 'package:flutter/material.dart';

  class AppColors {
  // Light theme colors
  static const Color primaryLight = Color(0xFF00965E);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF000000);
  // Dark theme colors
  static const Color primaryDark = Color(0xFF4CAF50);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textDark = Color(0xFFFFFFFF);

  // Static Colors
  static const Color border = Color(0xc9FFFFFF);
  static const Color grey = Color(0x99FFFFFF);

   // تعريف لوحة الألوان الأساسية للهوية البصرية
  static const Color primaryGreen = Color(0xFF00A78E); 
  static const Color backgroundMint = Color(0xFFE0F2F1);
  static const Color iconRed = Color(0xFFE57373);
  static const Color textGrey = Color(0xFF757575);

  // إعدادات الألوان الخاصة بالوضع الداكن (Dark Mode)
  static const Color darkBackground = Color(0xFF121212); // لون الخلفية الرئيسي للوضع الداكن
  static const Color darkCard = Color(0xFF1E1E1E);       // لون عناصر البطاقات (Cards) في الوضع الداكن

  // دالة تحديد لون النص لضمان وضوح التباين
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black;
  }
  // دالة استرداد لون الخلفية المتوافق مع الثيم الحالي
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : Colors.white;
  }


}

