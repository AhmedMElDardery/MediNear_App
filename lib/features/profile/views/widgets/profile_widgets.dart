import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart'; 

// 1. كارت المعلومات (Info Card)
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onEdit;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد لون الخلفية والنص حسب الثيم
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: cardColor, // ✅ لون ديناميكي
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), // ✅ ضل أتقل في الدارك
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 26),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor), // ✅ لون ديناميكي
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: textColor?.withOpacity(0.8)), // ✅ لون ديناميكي
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              child: const Icon(Icons.edit_square, color: AppColors.primaryLight, size: 22),
            ),
        ],
      ),
    );
  }
}

// 2. كارت الميزات (Feature Card) - ده المهم عشان الـ onTap
class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap; // ✅ موجود وجاهز

  const FeatureCard({super.key, required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Material( // ✅ استخدمنا Material عشان الـ InkWell يشتغل صح
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // ✅ تفعيل الضغط
        borderRadius: BorderRadius.circular(12),
        child: Ink( // استخدمنا Ink عشان الديكور واللون
          height: 90,
          decoration: BoxDecoration(
            color: cardColor, 
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 5, offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryLight, size: 32),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. كارت صغير (Small Card)
class SmallCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const SmallCard({super.key, required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 5, offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryLight, size: 24),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}