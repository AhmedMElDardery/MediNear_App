import 'package:flutter/material.dart';
import '../../data/models/saved_item_models.dart';

class SavedPharmacyCard extends StatelessWidget {
  final SavedPharmacyModel pharmacy;
  final VoidCallback onRemove;
  final ThemeData theme;

  const SavedPharmacyCard(
      {super.key,
      required this.pharmacy,
      required this.onRemove,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(theme),
      child: Row(
        children: [
          _imageBox(pharmacy.image, theme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacy.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pharmacy.location,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.bookmark, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3)),
      ],
    );
  }

  Widget _imageBox(String image, ThemeData theme, {double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image.startsWith('http')
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.local_pharmacy, color: theme.primaryColor),
              )
            : (image.isNotEmpty && image.startsWith('assets') 
                ? Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.local_pharmacy, color: theme.primaryColor),
                  )
                : Icon(Icons.local_pharmacy, color: theme.primaryColor)),
      ),
    );
  }
}

class SavedMedicationCard extends StatelessWidget {
  final SavedMedicationModel medication;
  final VoidCallback onRemove;
  final ThemeData theme;

  const SavedMedicationCard(
      {super.key,
      required this.medication,
      required this.onRemove,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(theme),
      child: Row(
        children: [
          _imageBox(medication.image, theme, size: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _availableTag(theme, medication.isAvailable),
                const SizedBox(height: 8),
                Text(
                  medication.name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  medication.price,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color),
                ),
                if (medication.pharmacyName != null && medication.pharmacyName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (medication.pharmacyImage != null && medication.pharmacyImage!.isNotEmpty)
                          ClipOval(
                            child: medication.pharmacyImage!.startsWith('http')
                                ? Image.network(medication.pharmacyImage!, width: 14, height: 14, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Icon(Icons.local_pharmacy, size: 14, color: theme.primaryColor))
                                : Image.asset(medication.pharmacyImage!, width: 14, height: 14, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Icon(Icons.local_pharmacy, size: 14, color: theme.primaryColor)),
                          )
                        else
                          Icon(Icons.local_pharmacy, size: 14, color: theme.primaryColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            medication.pharmacyName!,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.primaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.bookmark, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3)),
      ],
    );
  }

  Widget _imageBox(String image, ThemeData theme, {double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image.startsWith('http')
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.medication, color: theme.primaryColor),
              )
            : (image.isNotEmpty && image.startsWith('assets') 
                ? Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.medication, color: theme.primaryColor),
                  )
                : Icon(Icons.medication, color: theme.primaryColor)),
      ),
    );
  }

  Widget _availableTag(ThemeData theme, bool isAvailable) {
    if (!isAvailable) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: theme.primaryColor, borderRadius: BorderRadius.circular(4)),
      child: const Text('Available',
          style: TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
