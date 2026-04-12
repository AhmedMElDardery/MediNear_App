import 'package:flutter/material.dart';
import '../../domain/entities/pharmacy_entity.dart';

class PharmacyCard extends StatefulWidget {
  final PharmacyEntity pharmacy;
  final VoidCallback? onTap;

  const PharmacyCard({super.key, required this.pharmacy, this.onTap});

  @override
  State<PharmacyCard> createState() => _PharmacyCardState();
}

class _PharmacyCardState extends State<PharmacyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isOpen() {
    final hours = widget.pharmacy.workingHours;
    if (hours == null || hours.isEmpty) return true;
    try {
      final now = TimeOfDay.now();
      final nowMinutes = now.hour * 60 + now.minute;
      final parts = hours.split('-').map((e) => e.trim()).toList();
      if (parts.length < 2) return true;
      final open = _parseTime(parts[0]);
      final close = _parseTime(parts[1]);
      if (open == null || close == null) return true;
      if (close > open) return nowMinutes >= open && nowMinutes <= close;
      return nowMinutes >= open || nowMinutes <= close;
    } catch (_) {
      return true;
    }
  }

  int? _parseTime(String raw) {
    try {
      raw = raw.trim().toUpperCase();
      final isPm = raw.contains('PM');
      final isAm = raw.contains('AM');
      raw = raw.replaceAll('AM', '').replaceAll('PM', '').trim();
      if (raw.contains(':')) {
        final p = raw.split(':');
        int h = int.parse(p[0]);
        int m = int.parse(p[1]);
        if (isPm && h != 12) h += 12;
        if (isAm && h == 12) h = 0;
        return h * 60 + m;
      } else {
        int h = int.parse(raw);
        if (isPm && h != 12) h += 12;
        if (isAm && h == 12) h = 0;
        return h * 60;
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isOpen = _isOpen();
    final hasPhone = widget.pharmacy.phone != null && widget.pharmacy.phone!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: screenWidth * 0.78,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F5F2),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Circular Image ──────────────────────────
              _PharmacyAvatar(imageUrl: widget.pharmacy.image),

              const SizedBox(width: 14),

              // ── Info ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      widget.pharmacy.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Address + Distance — أخضر
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Color(0xFF00965E)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _buildSubtitle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00965E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (hasPhone) ...[
                      const SizedBox(height: 4),
                      // Phone — أخضر
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded,
                              size: 12, color: Color(0xFF00965E)),
                          const SizedBox(width: 3),
                          Text(
                            widget.pharmacy.phone!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00965E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 7),

                    // Open / Closed Badge
                    Row(
                      children: [
                        _StatusBadge(isOpen: isOpen),
                        if (widget.pharmacy.workingHours != null) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.pharmacy.workingHours!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Chevron ─────────────────────────────────
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFF00965E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (widget.pharmacy.address.isNotEmpty) parts.add(widget.pharmacy.address);
    if (widget.pharmacy.distance != null) parts.add(widget.pharmacy.distance!);
    return parts.join(' · ');
  }
}

// ── Open/Closed Badge ───────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF00965E) : const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circular Avatar ──────────────────────────────────────────
class _PharmacyAvatar extends StatelessWidget {
  final String imageUrl;
  const _PharmacyAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFB2DFDB),
      child: const Icon(
        Icons.local_pharmacy_rounded,
        size: 32,
        color: Color(0xFF00695C),
      ),
    );
  }
}