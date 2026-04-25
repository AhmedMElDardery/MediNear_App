class AppSuccessMessages {
  // 🚀 رسائل النجاح الثابتة في التطبيق
  static const String login = "Logged in successfully. Welcome back!";
  static const String logout = "Logged out successfully. See you soon!";
  static const String register = "Account created successfully!";
  static const String passwordReset = "Password reset link sent to your email.";

  // 🚀 دالة لو حابب تقرأ رسالة نجاح جاية من السيرفر نفسه (لو الباك إند باعت رسالة مخصصة)
  static String getCustomMessage(dynamic responseData, String defaultMessage) {
    if (responseData != null &&
        responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      return responseData['message'];
    }
    return defaultMessage;
  }
}
