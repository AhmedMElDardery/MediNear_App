import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/features/cart/data/models/cart_item_model.dart';
import '../manager/checkout_provider.dart';
import '../widgets/shipping_info_card.dart';
import '../widgets/payment_method_card.dart';

final checkoutProvider =
    ChangeNotifierProvider.autoDispose<CheckoutProvider>((ref) {
  return CheckoutProvider();
});

class CheckoutScreen extends ConsumerWidget {
  final double subtotal;
  final List<CartItemModel> pharmacyItems;
  final String pharmacyName;

  const CheckoutScreen({
    super.key,
    required this.subtotal,
    required this.pharmacyItems,
    required this.pharmacyName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    final checkout = ref.watch(checkoutProvider);
    final cart = ref.read(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Check Out",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const ShippingInfoCard(),
            const SizedBox(height: 25),
            const PaymentMethodCard(),
            const SizedBox(height: 25),
            _buildOrderSummary(cardColor, textColor, subtotal),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: checkout.isLoading
                    ? null
                    : () async {
                        bool success = await checkout.confirmOrder(
                            subtotal, pharmacyItems);

                        if (success) {
                          cart.loadCartPharmacies();

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Order Placed Successfully! 🎉"),
                                backgroundColor: Colors.green),
                          );

                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields! 🚨"),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                child: checkout.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Confirm Order",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
      Color cardColor, Color? textColor, double subtotal) {
    const double deliveryFee = 0.0;
    final double grandTotal = subtotal + deliveryFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Order Summary",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ]),
          child: Column(
            children: [
              _summaryRow(
                  "Subtotal", "${subtotal.toStringAsFixed(2)} EGP", textColor),
              const SizedBox(height: 10),
              _summaryRow("Delivery Fee", "Free", const Color(0xFF2E7D32),
                  isBold: true),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(thickness: 0.5)),
              _summaryRow("Grand Total", "${grandTotal.toStringAsFixed(2)} EGP",
                  textColor,
                  isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String title, String value, Color? color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: isBold ? color : Colors.grey[600],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
