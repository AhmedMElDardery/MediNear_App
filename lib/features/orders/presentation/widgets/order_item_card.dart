import 'package:flutter/material.dart';
// تأكد إن المسار ده صح للموديل بتاعك (لو الموديل في فولدر models)
import '../../data/models/order_item_model.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemModel item;

  const OrderItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // تظبيط الألوان (فاتح / غامق)
    final cardColor = Theme.of(context).cardColor;
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication_outlined,
                color: Theme.of(context).colorScheme.primary, size: 30),
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
              _buildBadge(context, "Price: ${item.price} EGP"),
              const SizedBox(height: 8),
              _buildBadge(context, "Total: ${item.total} EGP"),
            ],
          )
        ],
      ),
    );
  }

  // دالة صغيرة لرسم المربع الأخضر بتاع السعر
  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
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