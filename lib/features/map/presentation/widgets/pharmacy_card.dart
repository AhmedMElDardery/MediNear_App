import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 🚀 لازم تضيفها في الـ pubspec.yaml
import '../../domain/entities/pharmacy_entity.dart';

class PharmacyCard extends StatelessWidget {
  final PharmacyEntity item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onNotify;
  final VoidCallback? onAddToCart; // 🆕

  const PharmacyCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onNotify,
    this.onAddToCart,
  });

  // 🚀 دالة لفتح الروابط الخارجية (خرائط أو اتصال)
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF1E824C);
    const accentYellow = Color(0xFFFFC107);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? brandGreen.withValues(alpha: isDark ? 0.2 : 0.04) 
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandGreen : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.storefront, color: isDark ? Colors.grey[400] : Colors.grey[400], size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 4),
                          Text("${item.address} • ${item.distance.toStringAsFixed(1)} km",
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: accentYellow),
                              const SizedBox(width: 4),
                              const Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 10),
                              // 🚀 حالة التوفر بناءً على الداتا الحقيقية
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: item.hasMedicine 
                                        ? (isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green[50]) 
                                        : (isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red[50]),
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(
                                  item.hasMedicine ? "In Stock" : "Out of Stock",
                                  style: TextStyle(
                                      color: item.hasMedicine 
                                          ? (isDark ? Colors.green[400] : Colors.green[700]) 
                                          : (isDark ? Colors.red[400] : Colors.red[700]),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // --- زرار الاتجاهات (Route) ---
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // 🚀 بيفتح خرائط جوجل ويرسم الطريق لموقع الصيدلية
                          _launchURL('https://www.google.com/maps/search/?api=1&query=${item.lat},${item.lng}');
                        },
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text("Route"),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300)
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // --- زرار الاتصال أو الإشعار ---
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: item.hasMedicine
                            ? () => _launchURL('tel:123456789') // 🚀 حط هنا رقم الصيدلية لو موجود في الـ Entity
                            : onNotify,
                        icon: Icon(
                            item.hasMedicine ? Icons.call : Icons.notifications_active,
                            size: 16,
                            color: Colors.white
                        ),
                        label: Text(
                            item.hasMedicine ? "Call" : "Notify Me",
                            style: const TextStyle(color: Colors.white)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.hasMedicine ? brandGreen : Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            // 🚀 أيقونة السلة (Shopping Cart) تظهر فقط لو العلاج متاح
            if (item.hasMedicine)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_outlined,
                      color: brandGreen,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}