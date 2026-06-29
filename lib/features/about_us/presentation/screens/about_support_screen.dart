import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSupportScreen extends StatelessWidget {
  const AboutSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Gradient + Logo)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40,
                bottom: 40,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Real Logo
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // App Name
                  Text(
                    "MediNear",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Slogan in a beautiful pill shape
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "دوائك أقرب مما تتخيل",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  
                  // Description Card with Quote Icon
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "MediNear هو تطبيق ذكي يساعدك في العثور على الأدوية المتوفرة في أقرب صيدلية وطلبها بسهولة مع توصيل سريع وخدمات ذكية متقدمة.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Contact Us Section
                  Text(
                    "تواصل معنا",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildContactTile(
                    context,
                    theme,
                    title: "WhatsApp",
                    subtitle: "+201143173960",
                    iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 24),
                    color: const Color(0xFF25D366),
                    buttonText: "Chat now",
                    onTap: () async {
                      final url = Uri.parse("https://wa.me/201143173960");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactTile(
                    context,
                    theme,
                    title: "Email Us",
                    subtitle: "nharmdan15@gmail.com",
                    iconWidget: Icon(Icons.email_outlined, color: theme.colorScheme.primary, size: 24),
                    color: theme.colorScheme.primary,
                    buttonText: "Send Email",
                    onTap: () async {
                      final url = Uri.parse("mailto:nharmdan15@gmail.com");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),

                  const SizedBox(height: 40),
                  
                  // Footer (Version & Copyright)
                  Column(
                    children: [
                      Text(
                        "الإصدار 1.0.0",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "© 2026 MediNear. جميع الحقوق محفوظة.",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required Widget iconWidget,
    required Color color,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
