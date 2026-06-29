import 'package:flutter/material.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:intl/intl.dart';

class FolderCardWidget extends StatelessWidget {
  final PacketEntity packet;
  final VoidCallback onTap;

  const FolderCardWidget({
    super.key,
    required this.packet,
    required this.onTap,
  });

  Color _hexToColor(String hexString) {
    var hexColor = hexString.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final folderColor = _hexToColor(packet.colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : folderColor.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // � Background decorative elements
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: folderColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: -10,
                child: Icon(
                  Icons.folder_shared_rounded,
                  size: 60,
                  color: folderColor.withValues(alpha: 0.05),
                ),
              ),
              // � Main Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: folderColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            color: folderColor,
                            size: 28,
                          ),
                        ),
                        Icon(
                          Icons.more_vert_rounded,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      packet.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${packet.itemCount} Items",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd').format(packet.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
