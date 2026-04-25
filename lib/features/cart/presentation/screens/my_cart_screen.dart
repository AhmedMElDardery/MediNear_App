import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import 'package:medinear_app/features/cart/presentation/manager/cart_provider.dart';
import 'package:medinear_app/features/cart/presentation/widgets/cart_pharmacy_header.dart';
import 'package:medinear_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:medinear_app/features/checkout/presentation/screens/checkout_screen.dart';

class MyCartScreen extends ConsumerWidget {
  final String pharmacyName;

  const MyCartScreen({super.key, required this.pharmacyName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(cartProvider);
        final pharmacyItems = provider.getItemsByPharmacy(pharmacyName);
        final pharmacyTotal = provider.getPharmacyTotal(pharmacyName);

        // لو الصيدلية فضيت، ارجع للشاشة اللي فاتت
        if (pharmacyItems.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(pharmacyName,
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (pharmacyItems.isNotEmpty)
                  CartPharmacyHeader(
                    pharmacyName: pharmacyName,
                    location: pharmacyItems.first.pharmacyLocation,
                    productsCount: pharmacyItems.length,
                  ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: pharmacyItems.length,
                    itemBuilder: (context, index) {
                      final item = pharmacyItems[index];
                      return CartItemCard(
                        item: item,
                        onAdd: () => provider.incrementQuantity(item),
                        onRemove: () => provider.decrementQuantity(item),
                        onDelete: () => provider.deleteItem(item),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SafeArea(
                  child: _buildBottomSummary(context, pharmacyTotal,
                      pharmacyItems, cardColor, textColor),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSummary(BuildContext context, double total,
      List<dynamic> items, Color cardColor, Color? textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Text("${total.toInt()} EGP",
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                            subtotal: total,
                            pharmacyItems: List.from(
                                items), //  بنبعت منتجات الصيدلية دي بس
                            pharmacyName:
                                pharmacyName, //  وبنبعت الاسم عشان نمسحهم
                          )),
                );
              },
              child: const Text("Checkout",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
