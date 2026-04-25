import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import '../manager/pharmacy_provider.dart';
import '../widgets/pharmacy_cards.dart';
import '../../../../features/saved_items/presentation/manager/saved_items_provider.dart';
import '../../../../core/widgets/app_shimmer.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  final String pharmacyId; // 🚀 ضفنا الـ ID هنا عشان نبعته للـ API
  final String pharmacyName;
  final String doctorName;
  final String? pharmacyImage;

  const PharmacyScreen({
    super.key,
    required this.pharmacyId, // 🚀 خليناه مطلوب
    required this.pharmacyName,
    this.doctorName = 'Al-Noor Pharmacy',
    this.pharmacyImage,
  });
//...

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Countdown timer
  Timer? _timer;
  int _seconds = 10 * 3600 + 20 * 60 + 29; // 10:20:29

  static const _green = Color(0xFF00965E);
  static const _greenLight = Color(0xFFE0F5F2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isLocallySaved =
          ref.watch(savedItemsProvider).isPharmacySaved(widget.pharmacyId);
      // 🚀 هنا بنقول للبروفايدر: "روح هات بيانات الصيدلية بالـ ID بتاعها"
      ref
          .watch(pharmacyProvider)
          .fetchPharmacyData(widget.pharmacyId, isSavedLocally: isLocallySaved);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTime {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: Consumer(
          builder: (context, ref, _) {
            final provider = ref.watch(pharmacyProvider);
            return Column(
              children: [
                // ── Premium Header ──────────────────────
                _buildHeader(context),

                // ── Body ────────────────────────────────
                Expanded(
                  child: provider.isLoading
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: 5,
                          itemBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: AppShimmer(width: double.infinity, height: 120),
                          ),
                        )
                      : Column(
                          children: [
                            // Flash Sale Banner
                            _buildFlashSaleBanner(),

                            // Search Bar
                            _buildSearchBar(provider, isDark),

                            // Tab Bar
                            _buildTabBar(isDark),

                            // Tab Content
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildList(
                                    isDark: isDark,
                                    isEmpty: provider.filteredMedicines.isEmpty,
                                    emptyMsg: 'No medicines found',
                                    emptyIcon: Icons.medication_outlined,
                                    itemCount:
                                        provider.filteredMedicines.length,
                                    itemBuilder: (i) => PharmacyMedicineCard(
                                      medicine: provider.filteredMedicines[i],
                                      onToggleSave: () =>
                                          provider.toggleMedicineSaved(
                                              provider.filteredMedicines[i].id),
                                      onToggleNotify: () =>
                                          provider.toggleMedicineNotify(
                                              provider.filteredMedicines[i].id),
                                      onAddToCart: () => _showAddedToCart(
                                          provider.filteredMedicines[i].name),
                                    ),
                                  ),
                                  _buildList(
                                    isDark: isDark,
                                    isEmpty: provider.filteredDoctors.isEmpty,
                                    emptyMsg: 'No doctors found',
                                    emptyIcon: Icons.person_outline_rounded,
                                    itemCount: provider.filteredDoctors.length,
                                    itemBuilder: (i) => PharmacyDoctorCard(
                                      doctor: provider.filteredDoctors[i],
                                    ),
                                  ),
                                  _buildList(
                                    isDark: isDark,
                                    isEmpty: provider.filteredServices.isEmpty,
                                    emptyMsg: 'No services found',
                                    emptyIcon: Icons.medical_services_outlined,
                                    itemCount: provider.filteredServices.length,
                                    itemBuilder: (i) => PharmacyServiceCard(
                                      service: provider.filteredServices[i],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C47A), _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              // Top row — back + bookmark
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const Spacer(),
                  // 🚀 زرار الـ Save الجديد والمربوط بالـ API
                  Consumer(builder: (context, ref, child) {
                    final provider = ref.watch(pharmacyProvider);
                    return GestureDetector(
                      onTap: () async {
                        // 🚀 لما بتدوس، بينادي دالة الحفظ في البروفايدر
                        await provider.togglePharmacySave();
                        if (context.mounted) {
                          // 🚀 بنقول لصفحة المحفوظات تحدث بياناتها في الخلفية من غير ما تظهر لودينج
                          ref
                              .watch(savedItemsProvider)
                              .fetchSavedItems(silent: true);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                            // شكل الأيقونة بيتغير: مقفولة لو محفوظة، ومفتوحة لو لأ
                            provider.isPharmacySaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: Colors.white,
                            size: 28),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              // Info row — avatar + name
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.pharmacyImage != null &&
                              widget.pharmacyImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.pharmacyImage!,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              memCacheWidth: 160,
                              placeholder: (context, url) => const Icon(
                                  Icons.local_pharmacy_rounded,
                                  size: 42,
                                  color: _green),
                              errorWidget: (context, url, error) => const Icon(
                                  Icons.local_pharmacy_rounded,
                                  size: 42,
                                  color: _green),
                            )
                          : const Icon(Icons.local_pharmacy_rounded,
                              size: 42, color: _green),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pharmacyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Open badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle,
                                      size: 7, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('Open Now',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // FLASH SALE BANNER
  // ──────────────────────────────────────────────────────────
  Widget _buildFlashSaleBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('⚡', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Flash Sale!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(width: 8),
              Text('⚡', style: TextStyle(fontSize: 22)),
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle
          const Text(
            'Up to 50% off on all medicines',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          // Timer box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Time remaining',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SEARCH BAR
  // ──────────────────────────────────────────────────────────
  Widget _buildSearchBar(PharmacyProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          provider.search(val);
          setState(() {});
        },
        style: TextStyle(
            fontSize: 14, color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Search medicines, doctors...',
          hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _green, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    provider.search('');
                    setState(() {});
                  },
                  child: const Icon(Icons.close_rounded,
                      color: Colors.grey, size: 18),
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey.shade900 : const Color(0xFFF5F7FA),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // TAB BAR
  // ──────────────────────────────────────────────────────────
  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: _green,
        unselectedLabelColor:
            isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        indicatorColor: _green,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(
            icon: Icon(Icons.medication_rounded, size: 17),
            text: 'Medicines',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            icon: Icon(Icons.person_rounded, size: 17),
            text: 'Doctors',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            icon: Icon(Icons.medical_services_rounded, size: 17),
            text: 'Services',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // GENERIC LIST
  // ──────────────────────────────────────────────────────────
  Widget _buildList({
    required bool isDark,
    required bool isEmpty,
    required String emptyMsg,
    required IconData emptyIcon,
    required int itemCount,
    required Widget Function(int) itemBuilder,
  }) {
    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                  color: _greenLight, shape: BoxShape.circle),
              child: Icon(emptyIcon, size: 34, color: _green),
            ),
            const SizedBox(height: 14),
            Text(emptyMsg,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF444444))),
            const SizedBox(height: 4),
            Text('Try adjusting your search',
                style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: itemCount,
      itemBuilder: (ctx, i) => itemBuilder(i),
    );
  }

  void _showAddedToCart(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('$name added to cart')),
          ],
        ),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
