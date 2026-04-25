import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/ad_entity.dart';

class AdsSlider extends ConsumerStatefulWidget {
  final List<AdEntity> ads;

  const AdsSlider({super.key, required this.ads});

  @override
  ConsumerState<AdsSlider> createState() => _AdsSliderState();
}

class _AdsSliderState extends ConsumerState<AdsSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    if (widget.ads.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_userInteracting &&
          _controller.hasClients &&
          widget.ads.isNotEmpty) {
        final next = (_currentPage + 1) % widget.ads.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onUserInteractionStart() {
    _userInteracting = true;
    _autoPlayTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    // بعد 5 ثواني من آخر تفاعل يبدأ auto-play من جديد
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _userInteracting = false;
        _startAutoPlay();
      }
    });
  }

  void _openLink(String? url) async {
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint("Could not launch $url");
    }
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return const Color(0xFF00965E);
    String hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add opacity
    }
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildAdContent(AdEntity ad, bool isDark) {
    // Type 2: Color/Text Ad
    if (ad.backgroundColor != null && ad.backgroundColor!.isNotEmpty) {
      final Color bgColor = _parseColor(ad.backgroundColor);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              bgColor,
              // Make the top-right slightly lighter for a premium look
              Color.lerp(bgColor, Colors.white, 0.15) ?? bgColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative light glare on the top right corner
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Text on the right (First element in RTL)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns to right in RTL
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (ad.title != null && ad.title!.isNotEmpty)
                          Text(
                            ad.title!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 0.3,
                            ),
                          ),
                        if (ad.description != null && ad.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            ad.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                              height: 1.4,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Icon on the left (Second element in RTL)
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: (ad.iconUrl != null && ad.iconUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: ad.iconUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned Coupon Pill at the top-right
            if (ad.coupon != null && ad.coupon!.isNotEmpty)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ad.coupon!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('تم نسخ الكوبون: ${ad.coupon!}'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF00965E),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE), // Very light green
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ad.coupon!.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF00965E),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.local_activity_rounded, size: 16, color: Color(0xFFE53935)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Type 1: Image Ad (Existing logic)
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: ad.imageUrl,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          memCacheWidth: 800,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            highlightColor: isDark
                ? Colors.grey.shade700
                : Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00965E),
                  Color(0xFF00C47A)
                ],
              ),
            ),
            child: const Icon(Icons.local_pharmacy_rounded,
                size: 60, color: Colors.white),
          ),
        ),
        // Gradient overlay
        if (ad.title != null && ad.title!.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(16, 40, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xCC000000),
                    Colors.transparent
                  ],
                ),
              ),
              child: Text(
                ad.title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
        // Tap indicator
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded,
                    size: 12, color: Colors.white),
                SizedBox(width: 3),
                Text("Tap",
                    style: TextStyle(
                        fontSize: 11, color: Colors.white)),
              ],
            ),
          ),
        ),
        // Positioned Coupon Pill for Image Ads
        if (ad.coupon != null && ad.coupon!.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: ad.coupon!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('تم نسخ الكوبون: ${ad.coupon!}'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF00965E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE), // Very light green
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ad.coupon!.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF00965E),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.local_activity_rounded, size: 16, color: Color(0xFFE53935)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 175,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _onUserInteractionStart();
              } else if (notification is ScrollEndNotification) {
                _onUserInteractionEnd();
              }
              return false; // اسمح للـ PageView يكمل يشتغل
            },
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: widget.ads.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final ad = widget.ads[index];
                return GestureDetector(
                  onTap: () => _openLink(ad.redirectUrl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: index == _currentPage ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildAdContent(ad, isDark),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Dots Indicator
        if (widget.ads.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.ads.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00965E)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
