import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderHeaderCard extends StatelessWidget {
  final OrderModel order;
  const OrderHeaderCard({super.key, required this.order});

  // 🎨 دالة اختيار اللون حسب الحالة (الاحترافية هنا)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32); // أخضر
      case 'pending':
        return const Color(0xFFF57C00); // برتقالي
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFD32F2F); // أحمر
      default:
        return Colors.grey; // رصاصي لأي حاجة تانية
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    // بنحدد اللون هنا بناءً على حالة الطلب
    final statusColor = _getStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                child: const Icon(Icons.local_pharmacy, color: AppColors.primaryLight, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.pharmacyName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        Text(order.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // مربع الحالة باللون الديناميكي
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor, //  اللون متغير هنا
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Items: ${order.itemsCount}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              Text("Order Date: ${order.date}", style: TextStyle(fontSize: 12, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }
}