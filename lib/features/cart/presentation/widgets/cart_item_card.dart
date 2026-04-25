import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../../data/models/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onAdd; // دالة لما يدوس +
  final VoidCallback onRemove; // دالة لما يدوس -
  final VoidCallback onDelete; // دالة لما يدوس حذف

  const CartItemCard({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // الكارت الأساسي
        Container(
          margin: const EdgeInsets.only(top: 12), // عشان البادج اللي بارز فوق
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الدائرة الخضراء (الصورة)
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 15),

              // التفاصيل والعداد
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor)),
                    Text("${item.price.toInt()} EGP",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زرار الـ + و -
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: onRemove,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Icon(Icons.remove,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                              Text("x${item.quantity}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              InkWell(
                                onTap: onAdd,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // الإجمالي لكل صنف
                        Text(
                          "Total : ${item.totalPrice.toInt()} EGP",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // بادج Available (أخضر فوق على الشمال)
        if (item.isAvailable)
          Positioned(
            top: 2,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text("Available",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ),

        // زرار الحذف (أحمر فوق على اليمين)
        Positioned(
          top: 25,
          right: 15,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red, // لون أحمر صريح زي الصورة
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
