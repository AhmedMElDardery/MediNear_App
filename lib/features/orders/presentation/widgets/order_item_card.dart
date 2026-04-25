import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
// تأكد إن المسار ده صح للموديل بتاعك (لو الموديل في فولدر models)
import '../../data/models/order_item_model.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemModel item;

  const OrderItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // تظبيط الألوان (فاتح / غامق)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. صورة المنتج (مربع رمادي/أخضر فاتح)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_outlined,
                color: AppColors.primaryLight, size: 30),
          ),
          const SizedBox(width: 15),

          // 2. الاسم والكمية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor),
                ),
                const SizedBox(height: 5),
                Text(
                  "Qty: ${item.quantity}",
                  style: TextStyle(
                    color: textColor?.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 3. الأسعار (المربعات الخضراء)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBadge("Price: ${item.price} EGP"),
              const SizedBox(height: 8),
              _buildBadge("Total: ${item.total} EGP"),
            ],
          )
        ],
      ),
    );
  }

  // دالة صغيرة لرسم المربع الأخضر بتاع السعر
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32), // الأخضر الغامق
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
