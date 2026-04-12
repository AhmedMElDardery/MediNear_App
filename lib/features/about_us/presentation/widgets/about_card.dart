import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart'; //

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 20, 
            offset: const Offset(0, 8), 
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_circle, color: AppColors.primaryLight, size: 36), //
              SizedBox(width: 12),
              Text(
                "MediNear",
                style: TextStyle(
                  color: AppColors.primaryLight, //
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              children: [
                TextSpan(
                  text: "PharmaCare+",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " is your trusted digital pharmacy, making access easy with a wide range of services and fast delivery.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}