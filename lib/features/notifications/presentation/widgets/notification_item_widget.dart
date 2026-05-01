import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback onTap;

  const NotificationItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor.withOpacity(0.8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : item.iconColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🎨 Left thick colored strip
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: item.isRead ? Colors.transparent : item.iconColor,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✨ Squircle Icon
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: item.iconColor.withOpacity(isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(item.icon, color: item.iconColor, size: 26),
                        ),
                        const SizedBox(width: 16),
                        // 📝 Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                        color: theme.textTheme.bodyLarge?.color,
                                        letterSpacing: -0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: item.isRead
                                      ? theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // 🔴 Unread Dot Indicator
                        if (!item.isRead) ...[
                          const SizedBox(width: 12),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                )
                              ]
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
