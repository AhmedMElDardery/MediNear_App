import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';

class CartPharmacyHeader extends StatelessWidget {
  final String pharmacyName;
  final String location;
  final int productsCount;

  const CartPharmacyHeader({
    super.key,
    required this.pharmacyName,
    required this.location,
    required this.productsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            child: const Icon(Icons.store, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacyName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryLight),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.primaryLight),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$productsCount Products",
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}