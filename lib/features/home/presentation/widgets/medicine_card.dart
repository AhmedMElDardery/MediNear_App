import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import 'package:medinear_app/core/localization/translate_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:medinear_app/core/routes/routes.dart';
import '../../domain/entities/medicine_entity.dart';

class MedicineCard extends ConsumerStatefulWidget {
  final MedicineEntity medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  ConsumerState<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends ConsumerState<MedicineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.medicineDetails, extra: widget.medicine),
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.black.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image + Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: Container(
                      height: 105,
                      width: double.infinity,
                      color: Theme.of(context).cardColor,
                      child: widget.medicine.imageUrl.isNotEmpty
                          ? (widget.medicine.imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: widget.medicine.imageUrl,
                                  height: 105,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  memCacheWidth: 200,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Theme.of(context).dividerColor,
                                    highlightColor: Theme.of(context).cardColor,
                                    child: Container(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Center(
                                    child: Icon(
                                      Icons.medication_rounded,
                                      size: 45,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  widget.medicine.imageUrl,
                                  height: 105,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Icon(
                                      Icons.medication_rounded,
                                      size: 45,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ))
                          : Center(
                              child: Icon(
                                Icons.medication_rounded,
                                size: 45,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                  // Available badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:  Text(
                        AppLocalizations.of(context)!.translate("in_stock"),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name
                    Text(
                      widget.medicine.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.medicine.price.toStringAsFixed(0)} ${context.tr("currency_egp")}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              size: 18, color: Colors.white),
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
