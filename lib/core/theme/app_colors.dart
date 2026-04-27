import 'package:flutter/material.dart';

class AppColors {
  // -----------------------------------------
  // الألوان الدلالية - الوضع الفاتح (Light Theme)
  // -----------------------------------------
  // لون الهوية الرئيسي (البنفسجي) - يُستخدم في الأزرار والعناوين الرئيسية
  static const Color primaryLight = Color(0xFF00965E); 
  // لون الهوية الثانوي - يُستخدم للتنويع البصري أو العناصر الأقل أهمية
  static const Color secondaryLight = Color(0xFF00965E);
  // لون الخلفية الأساسي للتطبيق في الوضع الفاتح
  static const Color backgroundLight = Color(0xFFFFFFFF);
  // لون أسطح الكروت (Cards) والمساحات البيضاء
  static const Color surfaceLight = Color(0xFFF8FAFC);
  // لون سطحي بديل يُستخدم للتميز بين الأقسام
  static const Color surfaceLightVariant = Color(0xFFF1F5F9);
  
  // لون النصوص الأساسي (داكن جداً للوضوح)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  // لون النصوص الثانوية والشروحات (رمادي متوسط)
  static const Color textSecondaryLight = Color(0xFF475569);
  // لون نصوص التلميحات (Hints) داخل حقول الإدخال
  static const Color textHintLight = Color(0xFF94A3B8);

  // لون الفواصل والحدود (Dividers & Borders) في الوضع الفاتح
  static const Color dividerLight = Color(0xFFE2E8F0);
  
  // -----------------------------------------
  // الألوان الدلالية - الوضع الداكن (Dark Theme)
  // -----------------------------------------
  // لون الهوية الرئيسي في الوضع الداكن
  static const Color primaryDark = Color(0xFF00965E); 
  // لون الهوية الثانوي في الوضع الداكن
  static const Color secondaryDark = Color(0xFF00965E);
  // لون الخلفية الأساسي في الوضع الداكن
  static const Color backgroundDark = Color(0xFF121212);
  // لون أسطح الكروت في الوضع الداكن
  static const Color surfaceDark = Color(0xFF1E1E1E);
  // لون سطحي بديل في الوضع الداكن
  static const Color surfaceDarkVariant = Color(0xFF2D2D2D);

  // لون النصوص الأساسي في الوضع الداكن (أبيض مائل للزرقة)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  // لون النصوص الثانوية في الوضع الداكن
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  // لون نصوص التلميحات في الوضع الداكن
  static const Color textHintDark = Color(0xFF64748B);

  // لون الفواصل والحدود في الوضع الداكن
  static const Color dividerDark = Color(0xFF333333);

  // -----------------------------------------
  // ألوان الحالات (النجاح، الخطأ، التحذير، المعلومات)
  // -----------------------------------------
  // لون النجاح (مربوط حالياً بلون البراند لتوحيد الهوية)
  static const Color success = Color(0xFF321D75);
  // لون الخطأ (الأحمر) - يُستخدم في رسائل التنبيه والأخطاء
  static const Color error = Color(0xFFEF4444);
  // لون التحذير (البرتقالي/الأصفر)
  static const Color warning = Color(0xFFF59E0B);
  // لون المعلومات (الأزرق)
  static const Color info = Color(0xFF3B82F6);

  // -----------------------------------------
  // ألوان ثابتة أساسية
  // -----------------------------------------
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;


  // -----------------------------------------
  // Helper Methods
  // -----------------------------------------
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
}
