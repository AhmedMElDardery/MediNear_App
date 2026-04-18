import 'package:flutter/material.dart';
import 'package:medinear_app/features/support/presentation/provider/support_provider.dart';
import 'package:medinear_app/features/support/presentation/widgets/support_card.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SupportProvider>(context, listen: false).init(context));
  }

  void _showFeedbackBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int selectedRating = 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? theme.dividerColor : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "How was your experience?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? theme.textTheme.bodyLarge?.color ?? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your feedback helps us improve our service.",
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 44,
                            color: index < selectedRating ? const Color(0xFFF59E0B) : (isDark ? theme.dividerColor.withOpacity(0.5) : Colors.grey.shade300),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.2) : Colors.grey.shade200),
                    ),
                    child: TextField(
                      maxLines: 3,
                      style: TextStyle(color: isDark ? theme.textTheme.bodyLarge?.color ?? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Tell us more (optional)...",
                        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: selectedRating > 0 ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Thank you for your feedback! ❤️", style: TextStyle(fontWeight: FontWeight.bold)), 
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        disabledBackgroundColor: isDark ? theme.dividerColor : Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Submit Feedback", 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w700, 
                          color: selectedRating > 0 ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade400)
                        )
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildStaticOption(String title, String subtitle, IconData iconData, Color primaryColor, int index, {VoidCallback? onTap, required ThemeData theme}) {
    final isDark = theme.brightness == Brightness.dark;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.1)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.05 : 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: primaryColor.withOpacity(0.12),
                      border: Border.all(color: primaryColor.withOpacity(0.1)),
                    ),
                    child: Icon(
                      iconData,
                      size: 24,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? theme.textTheme.bodyLarge?.color ?? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 13, height: 1.2)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(FaIconData icon, Color color, {required ThemeData theme}) {
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.1) : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.05 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupportProvider>(context);
    final itemsCount = provider.items.length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: Text(
          "Support & Help",
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 20, 
            color: isDark ? theme.textTheme.titleLarge?.color ?? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                shape: BoxShape.circle,
                border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.2)) : null,
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Icon(Icons.arrow_back_rounded, color: isDark ? theme.iconTheme.color ?? Colors.white : const Color(0xFF0F172A), size: 20),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  shape: BoxShape.circle,
                  border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.2)) : null,
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Icon(Icons.more_horiz_rounded, color: isDark ? theme.iconTheme.color ?? Colors.white : const Color(0xFF0F172A), size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Premium Gradient Top Banner
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0), 
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF172554), const Color(0xFF1E3A8A)] 
                      : const [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : const Color(0xFF3B82F6).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: isDark ? Colors.white.withOpacity(0.05) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage("assets/images/image_support.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How can we\nhelp you?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "We are ready to assist you anytime.",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 24, bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.1) : Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.05 : 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: isDark ? theme.textTheme.bodyLarge?.color ?? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "What do you need help with?",
                    hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),

            // Active Order Support Card
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [const Color(0xFF7A2E0D), const Color(0xFF431407)] 
                        : const [Color(0xFFFFF7ED), Color(0xFFFFEDD5)], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? const Color(0xFF9A3412).withOpacity(0.5) : const Color(0xFFFDBA74).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFF97316).withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF431407) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withOpacity(0.2) : const Color(0xFFF97316).withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      ),
                      child: Icon(Icons.local_shipping_rounded, color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFF97316), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Having an issue?", style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            "Active Order", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF7C2D12), letterSpacing: -0.3)
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      child: const Text("Get Help", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),

            // Dynamic provider items
            ...provider.items.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return SupportCard(item: item, index: index);
            }).toList(),

            const SizedBox(height: 8),

            // Extra static options with premium styling and interactive feedback
            _buildStaticOption("Help & FAQs", "Frequently asked questions", Icons.help_center_rounded, const Color(0xFF0EA5E9), itemsCount, theme: theme),
            _buildStaticOption("Feedback", "Rate us & share your thoughts", Icons.star_rounded, const Color(0xFFF59E0B), itemsCount + 1, onTap: () => _showFeedbackBottomSheet(context), theme: theme),
            _buildStaticOption("Privacy Policy", "Terms and privacy policy", Icons.privacy_tip_rounded, const Color(0xFF8B5CF6), itemsCount + 2, theme: theme),
            
            const SizedBox(height: 32),

            // Social Media Row
            Text("Follow us on", style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(FontAwesomeIcons.facebookF, const Color(0xFF1877F2), theme: theme),
                const SizedBox(width: 16),
                _buildSocialIcon(FontAwesomeIcons.instagram, const Color(0xFFE4405F), theme: theme),
                const SizedBox(width: 16),
                _buildSocialIcon(FontAwesomeIcons.twitter, const Color(0xFF1DA1F2), theme: theme),
                const SizedBox(width: 16),
                _buildSocialIcon(FontAwesomeIcons.youtube, const Color(0xFFFF0000), theme: theme),
              ],
            ),
            const SizedBox(height: 48),

            // App Version Footer
            Column(
              children: [
                Text("MediNear App v1.0.0", style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Made with ", style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
                    const Icon(Icons.favorite_rounded, color: Color(0xFFF43F5E), size: 14),
                    Text(" for your health", style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}