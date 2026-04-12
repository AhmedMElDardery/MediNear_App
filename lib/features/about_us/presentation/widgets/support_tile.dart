import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart'; //

class SupportTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData? trailingIcon;

  const SupportTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppColors.primaryLight, size: 26), //
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textLight, //
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.grey[400], size: 22),
        ],
      ),
    );
  }
}