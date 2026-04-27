import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: theme.textTheme.bodyLarge?.color,
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
