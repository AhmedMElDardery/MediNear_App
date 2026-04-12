import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  // 🎨 دالة اختيار اللون
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
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final statusColor = _getStatusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            // 1. الصف الأول: اللوجو + الاسم + الحالة
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  child: const Icon(Icons.local_pharmacy, color: AppColors.primaryLight),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.pharmacyName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // بادج الحالة الملون
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 0.5),
            ),

            // 2. الصف الثاني: عدد العناصر والسعر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Items: ${order.itemsCount}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Text(
                  "${order.total} EGP",
                  style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            
            const SizedBox(height: 10),

            // 3. الصف الثالث: التاريخ + زرار View Details (اللي رجعناه) 👇
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${order.date}",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                // زرار التفاصيل (شكل بس، والضغطة بتمسكها الكارت كله)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}