import 'package:flutter/material.dart';
import 'package:medinear_app/features/medication/data/models/medication_model.dart';
// ✅ المسار صحيح ومطابق للهيكلة الجديدة

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onDelete;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ✅ استبدال withOpacity بـ withValues (لحل تنبيه الـ Info)
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medication,
                      color: isDarkMode ? Colors.white70 : Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // ✅ استخدام withValues بدلاً من withOpacity
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.access_time,
                      size: 18, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medication.description,
                    style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionIcon(
                          Icons.info_outline,
                          Theme.of(context).primaryColor,
                          // ✅ تحديث هنا أيضاً
                          Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: _buildActionIcon(
                            Icons.delete_outline,
                            Colors.redAccent,
                            // ✅ تحديث هنا أيضاً
                            Colors.redAccent.withValues(alpha: 0.1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
