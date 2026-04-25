import 'package:flutter/material.dart';
import '../../data/models/pharmacy_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PharmacyMedicineCard extends StatelessWidget {
  final PharmacyMedicineModel medicine;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleNotify;
  final VoidCallback onAddToCart;

  const PharmacyMedicineCard(
      {super.key,
      required this.medicine,
      required this.onToggleSave,
      required this.onToggleNotify,
      required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: isDark
                    ? Colors.black38
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: medicine.image.startsWith('http')
                  ? CachedNetworkImage(imageUrl: medicine.image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(Icons.medication,
                          color: theme.primaryColor, size: 40))
                  : Image.asset(medicine.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.medication,
                          color: theme.primaryColor, size: 40)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (medicine.discount > 0)
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('${medicine.discount}% off',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold))),
                    const Spacer(),
                    IconButton(
                        icon: Icon(
                            medicine.isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: theme.primaryColor,
                            size: 20),
                        onPressed: onToggleSave),
                  ],
                ),
                Text(medicine.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 4),
                Text('${medicine.oldPrice} EGP',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${medicine.price} EGP',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor)),
                    const Spacer(),
                    if (medicine.inStock)
                      IconButton(
                          icon: Icon(Icons.shopping_cart,
                              color: theme.primaryColor),
                          onPressed: onAddToCart)
                    else
                      ElevatedButton(
                        onPressed: onToggleNotify,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: medicine.notifyAvailable
                                ? Colors.grey
                                : Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: Text(
                            medicine.notifyAvailable
                                ? 'Notified'
                                : 'Not Available',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PharmacyDoctorCard extends StatelessWidget {
  final PharmacyDoctorModel doctor;

  const PharmacyDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: isDark
                    ? Colors.black38
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: doctor.image != null && doctor.image!.isNotEmpty
                ? (doctor.image!.startsWith('http')
                    ? CachedNetworkImageProvider(doctor.image!)
                    : AssetImage(doctor.image!)) as ImageProvider
                : null,
            onBackgroundImageError: (_, __) {},
            child: (doctor.image == null || doctor.image!.trim().isEmpty)
                ? Icon(Icons.person, size: 35, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 4),
                Text(doctor.specialty,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${doctor.rating}',
                      style:
                          TextStyle(color: theme.textTheme.bodyMedium?.color))
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PharmacyServiceCard extends StatelessWidget {
  final PharmacyServiceModel service;

  const PharmacyServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: isDark
                    ? Colors.black38
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: service.image.startsWith('http')
                  ? CachedNetworkImage(imageUrl: service.image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(Icons.medical_services,
                          color: theme.primaryColor, size: 40))
                  : Image.asset(service.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.medical_services,
                          color: theme.primaryColor, size: 40)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(service.duration,
                      style: const TextStyle(fontSize: 14, color: Colors.grey))
                ]),
                const SizedBox(height: 4),
                Text('${service.price} EGP',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
