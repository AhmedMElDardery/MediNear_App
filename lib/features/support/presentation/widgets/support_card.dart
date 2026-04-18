import 'package:flutter/material.dart';
import 'package:medinear_app/features/support/data/models/support_item_model.dart';



class SupportCard extends StatelessWidget {
  final SupportItemModel item;

  const SupportCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 24,
              color: _getIconColor(item.title),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(item.subtitle,
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () => item.onTap(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getIconColor(item.title),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(item.buttonText, style: const TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

Color _getIconColor(String title) {
  switch (title) {
    case "Call Us":
      return Color(0xFF4CAF50);
    case "WhatsApp":
      return Color(0xFF4CAF50);
    case "Email Us":
      return Color(0xFF2196F3);
    default:
      return Colors.black;
  }
}