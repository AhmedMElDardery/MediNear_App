import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../manager/about_provider.dart';
import '../widgets/about_card.dart';
import '../widgets/support_tile.dart';

class AboutSupportScreen extends ConsumerStatefulWidget {
  const AboutSupportScreen({super.key});

  @override
  ConsumerState<AboutSupportScreen> createState() => _AboutSupportScreenState();
}

class _AboutSupportScreenState extends ConsumerState<AboutSupportScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 جلب البيانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(aboutProvider).loadAboutData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("About Us & Support",
            style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final provider = ref.watch(aboutProvider);
          if (provider.isLoading) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.primary));
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AboutCard(),
                const SizedBox(height: 30),
                Text("Support",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 15),

                // 🚀 عرض خيارات الدعم من البروفايدر
                ...provider.supportOptions.map((option) => SupportTile(
                      leadingIcon: option.icon,
                      title: option.title,
                      trailingIcon: option.trailingIcon,
                    )),

                const SizedBox(height: 30),
                Text("Follow Us",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 15),
                _buildFollowUsCard(provider.version),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowUsCard(String version) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
          )
        ],
      ),
      child: Row(
        children: [
          Text("App Version $version",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color)),
          const Spacer(),
          // ✅ تم التغيير لـ FaIcon لحل الإيرور
          const FaIcon(FontAwesomeIcons.facebook,
              color: Color(0xFF1877F2), size: 24),
          const SizedBox(width: 15),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFCAF45)],
            ).createShader(bounds),
            // ✅ تم التغيير لـ FaIcon هنا أيضاً
            child: const FaIcon(FontAwesomeIcons.instagram,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
