import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double totalOrderPrice;
  const PaymentSummaryCard({super.key, required this.totalOrderPrice});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text("Payment Summary",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildRow("Subtotal", "$totalOrderPrice EGP", textColor,
              isBold: false),
          const SizedBox(height: 12),
          _buildRow("Shipping", "Free", Theme.of(context).colorScheme.primary,
              isBold: true),
          const SizedBox(height: 12),
          _buildRow("Payment Type", "Paymob Visa", textColor, isBold: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Grand Total",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor)),
              Text("$totalOrderPrice EGP",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }

  // دالة مساعدة للسطور العادية
  Widget _buildRow(String label, String value, Color? valueColor,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: 14)),
      ],
    );
  }
}
