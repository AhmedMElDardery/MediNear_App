import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/features/auth/presentation/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 🚀 1. خلفية النقوش الطبية
            Positioned.fill(
              child: _buildMedicalPatternBackground(isDark),
            ),

            // 🚀 2. المحتوى الأساسي
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // 🚀 اللوجو بتاعك الحقيقي
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white : Colors.white, // To keep the white background for logo image
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png', // ⚠️ تأكد من المسار واسم الصورة
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🚀 كلمة Digital Pharmacy
                    const Text(
                      " MidiNear Pharmacies",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Cairo',
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Log in to continue",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // 🚀 زرار جوجل
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: _buildLoginButton(
                        text: "Log in with Google",
                        iconWidget: Image.network(
                          'https://img.icons8.com/color/48/000000/google-logo.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const FaIcon(FontAwesomeIcons.google, color: Color(0xFFDB4437), size: 22);
                          },
                        ),
                        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        textColor: isDark ? Colors.white : Colors.black87,
                        shadowColor: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.08),
                        isDark: isDark,
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final success = await authProvider.loginWithGoogle();

                          if (success) {
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, AppRoutes.home);
                          } else if (authProvider.errorMessage != null) {
                            if (!context.mounted) return;
                            _showTopError(context, authProvider.errorMessage!);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🚀 فاصل or
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text("or", style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey, fontSize: 14)),
                          ),
                          Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, thickness: 1)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🚀 زرار فيسبوك
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: _buildLoginButton(
                        text: "Log in with Facebook",
                        iconWidget: const FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 22),
                        backgroundColor: const Color(0xFF3B5998),
                        textColor: Colors.white,
                        shadowColor: const Color(0xFF3B5998).withValues(alpha: 0.3),
                        isDark: isDark,
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final success = await authProvider.loginWithFacebook();

                          if (success) {
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, AppRoutes.home);
                          } else if (authProvider.errorMessage != null) {
                            if (!context.mounted) return;
                            _showTopError(context, authProvider.errorMessage!);
                          }
                        },
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),

            // 🚀 3. شاشة التحميل
            if (Provider.of<AuthProvider>(context).isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🚀🔥 تصميم البطاقة العائمة مع الأنيميشن (نزلت لتحت شوية)
  void _showTopError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          // 🚀 الرقم ده اتعدل لـ 160 عشان الرسالة تنزل لتحت شوية
          bottom: MediaQuery.of(context).size.height - 160,
          left: 15,
          right: 15,
        ),
        content: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF5350), Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Oops! Error",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      child: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                    )
                  ],
                ),
              ),

              // 🚀 شريط التحميل المتحرك
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: 0.0),
                duration: const Duration(seconds: 4),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.transparent,
                    minHeight: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.6),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🚀 دالة بناء نقشة الخلفية الطبية
  Widget _buildMedicalPatternBackground(bool isDark) {
    final List<Widget> iconWidgets = [
      FaIcon(FontAwesomeIcons.pills, color: Colors.green[200], size: 30),
      FaIcon(FontAwesomeIcons.capsules, color: Colors.green[200], size: 30),
      FaIcon(FontAwesomeIcons.prescriptionBottle, color: Colors.green[200], size: 30),
      FaIcon(FontAwesomeIcons.syringe, color: Colors.green[200], size: 30),
      FaIcon(FontAwesomeIcons.stethoscope, color: Colors.green[200], size: 30),
      Icon(Icons.medical_services_outlined, color: Colors.green[200], size: 30),
      Icon(Icons.local_pharmacy_outlined, color: Colors.green[200], size: 30),
      Icon(Icons.healing_outlined, color: Colors.green[200], size: 30),
      Icon(Icons.biotech_outlined, color: Colors.green[200], size: 30),
      FaIcon(FontAwesomeIcons.userDoctor, color: Colors.green[200], size: 30),
      FaIcon(FontAwesomeIcons.hospital, color: Colors.green[200], size: 30),
    ];

    return Opacity(
      opacity: isDark ? 0.05 : 0.3,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 35,
          crossAxisSpacing: 35,
        ),
        itemCount: 120,
        itemBuilder: (context, index) {
          final widget = iconWidgets[index % iconWidgets.length];
          double rotation = (index % 4) * 0.4;

          return Transform.rotate(
            angle: rotation,
            child: widget,
          );
        },
      ),
    );
  }

  // 🚀 ويدجت زراير تسجيل الدخول
  Widget _buildLoginButton({
    required String text,
    required Widget iconWidget,
    required Color backgroundColor,
    required Color textColor,
    required Color shadowColor,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: (backgroundColor == Colors.white || backgroundColor == const Color(0xFF1E1E1E))
              ? Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}