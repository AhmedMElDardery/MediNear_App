import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../manager/about_provider.dart';
import '../widgets/about_card.dart';
import '../widgets/support_tile.dart';

class AboutSupportScreen extends StatefulWidget {
  const AboutSupportScreen({super.key});

  @override
  State<AboutSupportScreen> createState() => _AboutSupportScreenState();
}

class _AboutSupportScreenState extends State<AboutSupportScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 جلب البيانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AboutProvider>(context, listen: false).loadAboutData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("About Us & Support", style: TextStyle(color: isDark ? Colors.white : AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Consumer<AboutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AboutCard(),
                const SizedBox(height: 30),
                Text("Support", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 15),

                // 🚀 عرض خيارات الدعم من البروفايدر
                ...provider.supportOptions.map((option) => SupportTile(
                  leadingIcon: option.icon,
                  title: option.title,
                  trailingIcon: option.trailingIcon,
                )),

                const SizedBox(height: 30),
                Text("Follow Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 15),
                _buildFollowUsCard(provider.version, isDark),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowUsCard(String version, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 15,
          )
        ],
      ),
      child: Row(
        children: [
          Text("App Version $version", style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : AppColors.textLight)),
          const Spacer(),
          // ✅ تم التغيير لـ FaIcon لحل الإيرور
          const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 24),
          const SizedBox(width: 15),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFCAF45)],
            ).createShader(bounds),
            // ✅ تم التغيير لـ FaIcon هنا أيضاً
            child: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}