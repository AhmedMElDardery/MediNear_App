import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double totalOrderPrice;
  const PaymentSummaryCard({super.key, required this.totalOrderPrice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Summary",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          const SizedBox(height: 15),

          // ✅ التعديل الأول: الشحن بقى مجاني وبلون أخضر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Shipping :",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14)),
              const Text("Free",
                  style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ التعديل التاني: شيلنا الـ 20 جنيه من الإجمالي
          _buildRow("Total Price :", "$totalOrderPrice EGP", textColor),
          const SizedBox(height: 10),

          _buildRow("Payment Type :", "Paymob Visa", textColor),
        ],
      ),
    );
  }

  // دالة مساعدة للسطور العادية
  Widget _buildRow(String label, String value, Color? textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: textColor?.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }
}
