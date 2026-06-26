import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_header_card.dart';
import '../widgets/order_item_card.dart';
import '../widgets/payment_summary_card.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Order Details",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timeline Stepper
            _buildTimeline(context, order.status, cardColor, textColor),
            const SizedBox(height: 25),

            OrderHeaderCard(order: order),
            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Order Items",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ),
            const SizedBox(height: 15),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return OrderItemCard(item: order.items[index]);
              },
            ),

            const SizedBox(height: 25),
            PaymentSummaryCard(totalOrderPrice: order.total),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
      BuildContext context, String status, Color cardColor, Color? textColor) {
    final primary = Theme.of(context).colorScheme.primary;
    final isCompleted = status.toLowerCase() == 'completed';
    final isCanceled = status.toLowerCase() == 'canceled' ||
        status.toLowerCase() == 'cancelled';
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(context, Icons.inventory_2_outlined, "Pending", true,
              primary, textColor),
          _buildLine(context, !isPending && !isCanceled, primary),
          _buildStep(
              context,
              Icons.local_shipping_outlined,
              isCanceled ? "Canceled" : "Processing",
              !isPending,
              isCanceled ? Colors.red : primary,
              textColor),
          _buildLine(context, isCompleted, primary),
          _buildStep(context, Icons.check_circle_outline, "Completed",
              isCompleted, primary, textColor),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, IconData icon, String label,
      bool isActive, Color activeColor, Color? textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, color: isActive ? activeColor : Colors.grey, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? textColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, bool isActive, Color activeColor) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 20), // Align with icons
        alignment: Alignment.topCenter,
        color: isActive ? activeColor : Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }
}
