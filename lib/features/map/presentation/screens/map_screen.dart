import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import '../provider/map_provider.dart';
import '../widgets/pharmacy_card.dart';
import 'package:medinear_app/features/pharmacy/presentation/screens/pharmacy_screen.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import 'package:medinear_app/core/widgets/app_shimmer.dart';
import 'package:medinear_app/core/widgets/custom_empty_state.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String medicine;
  const MapScreen({super.key, required this.medicine});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Color _brandGreen = const Color(0xFF1E824C);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = ref.read(mapProvider);
      await provider.initLocation();

      // تأكد إننا بنحمل البيانات لو مش موجودة
      if (provider.medicineSuggestions.isEmpty) {
        provider.loadSearchData();
      }

      // البحث عن الدواء إذا تم تمريره من شاشة أخرى
      if (widget.medicine.isNotEmpty) {
        _searchController.text = widget.medicine;
        provider.isMedicineSearch = true;
        provider.search(widget.medicine);
      }
    });

    // 🚀 مراقبة الفوكس
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        ref.read(mapProvider).setShowSuggestions(false);
      }
    });

    // 🚀 الفلترة اللحظية (Real-time Filtering)
    _searchController.addListener(() {
      if (mounted) {
        setState(() {}); // بيخلي ويدجت الاقتراحات تعيد بناء نفسها مع كل حرف
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(mapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- Layer 1: Google Map ---
          Positioned.fill(
            child: provider.userLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    style: isDark ? _darkMapStyle : null,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                        target: provider.userLocation!, zoom: 13.5),
                    markers: provider.markers,
                    circles: provider.circles,
                    onMapCreated: (controller) {
                      if (!provider.mapController.isCompleted) {
                        provider.mapController.complete(controller);
                      }
                    },
                    onTap: (_) {
                      _searchFocusNode.unfocus(); // يقفل الكيبورد والاقتراحات
                      provider.setShowSuggestions(false);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
          ),

          // --- Layer 2: Search Suggestions Overlay ---
          if (provider.showSuggestions)
            _buildSearchSuggestions(provider, isDark),

          // --- Layer 3: Glass Search Header ---
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildGlassSearchHeader(provider, isDark)),

          // --- Layer 4: Floating My Location Button ---
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.42,
            child: FloatingActionButton(
              onPressed: () async {
                if (provider.userLocation != null) {
                  final controller = await provider.mapController.future;
                  controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: provider.userLocation!, zoom: 16.0)));
                }
              },
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Icon(Icons.my_location,
                  color: isDark ? Colors.white : Colors.black87),
            ),
          ),

          // --- Layer 5: Draggable Bottom Sheet ---
          if (!provider.showSuggestions)
            _buildResultsBottomSheet(provider, isDark),
        ],
      ),
    );
  }

  // 🚀 ويدجت الاقتراحات - تعرض أدوية أو صيدليات حسب نوع البحث
  Widget _buildSearchSuggestions(MapProvider provider, bool isDark) {
    final query = _searchController.text.trim().toLowerCase();

    // 1. فلترة البحث الأخير
    final filteredRecent = query.isEmpty
        ? provider.recentSearches
        : provider.recentSearches
            .where((s) => s.displayText.toLowerCase().contains(query))
            .toList();

    final bool isMedicine = provider.isMedicineSearch;

    // 2a. لو Medicine mode: فلترة الأدوية
    final filteredMedicines = isMedicine
        ? (query.isEmpty
            ? provider.medicineSuggestions
            : provider.medicineSuggestions
                .where((m) => m.name.toLowerCase().contains(query))
                .toList())
        : [];

    // 2b. لو Pharmacy mode: فلترة الصيدليات
    final filteredPharmacies = !isMedicine
        ? (query.isEmpty
            ? provider.pharmacySuggestions
            : provider.pharmacySuggestions
                .where((p) => p.name.toLowerCase().contains(query))
                .toList())
        : [];

    final bool isEmpty = filteredRecent.isEmpty &&
        filteredMedicines.isEmpty &&
        filteredPharmacies.isEmpty;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 130,
      left: 16,
      right: 16,
      bottom: 100,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: isEmpty
              ? CustomEmptyState(
                  title: 'noSuggestionsMatch'.tr(context),
                  subtitle: "Try adjusting your search criteria.",
                  icon: Icons.search_off_rounded,
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // --- Recent Searches ---
                          if (filteredRecent.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                  query.isEmpty
                                      ? 'recentSearches'.tr(context)
                                      : 'matchingRecent'.tr(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ),
                            ...filteredRecent.map((s) => ListTile(
                                  leading: const Icon(Icons.history, size: 20),
                                  title: Text(s.displayText),
                                  onTap: () {
                                    _searchController.text = s.displayText;
                                    provider.search(s.medicineId?.toString() ??
                                        s.displayText);
                                    _searchFocusNode.unfocus();
                                  },
                                )),
                          ],
                          // --- Medicine Suggestions ---
                          if (isMedicine && filteredMedicines.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                  query.isEmpty
                                      ? 'availableMedicines'.tr(context)
                                      : 'matchingMedicines'.tr(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ),
                            ...filteredMedicines.map((m) => ListTile(
                                  leading: const Icon(Icons.medication_outlined,
                                      color: Color(0xFF1E824C)),
                                  title: Text(m.name),
                                  subtitle: m.categoryName != null
                                      ? Text(m.categoryName!,
                                          style: const TextStyle(fontSize: 10))
                                      : null,
                                  onTap: () {
                                    _searchController.text = m.name;
                                    provider.search(m.id.toString());
                                    _searchFocusNode.unfocus();
                                  },
                                )),
                          ],
                          // --- Pharmacy Suggestions ---
                          if (!isMedicine && filteredPharmacies.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                  query.isEmpty
                                      ? 'nearbyPharmacies'.tr(context)
                                      : 'matchingPharmacies'.tr(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ),
                            ...filteredPharmacies.map((p) => ListTile(
                                  leading: const Icon(Icons.storefront,
                                      color: Color(0xFF1E824C)),
                                  title: Text(p.name),
                                  subtitle: Text(p.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11)),
                                  onTap: () {
                                    _searchController.text = p.name;
                                    provider.search(p.name);
                                    _searchFocusNode.unfocus();
                                  },
                                )),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGlassSearchHeader(MapProvider provider, bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: isDark
              ? const Color(0xFF121212).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.90),
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 15,
              left: 16,
              right: 16),
          child: Column(
            children: [
              Row(
                children: [
                  // 🚀 شيلنا الـ GestureDetector بتاع الدائرة البيضاء وشيلنا الـ SizedBox اللي بعده
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      // 🚀 علامة العدسة في الكيبورد
                      textInputAction: TextInputAction.search,
                      onTap: () {
                        provider.setShowSuggestions(true);
                      },
                      onChanged: (val) {
                        if (!provider.showSuggestions) {
                          provider.setShowSuggestions(true);
                        }
                      },
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          provider.search(val.trim());
                        }
                        _searchFocusNode.unfocus();
                      },
                      decoration: InputDecoration(
                        hintText: provider.isMedicineSearch
                            ? 'searchMedicineHint'.tr(context)
                            : 'searchPharmacyHint'.tr(context),
                        hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.grey, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setShowSuggestions(true);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade900 : Colors.grey[100],
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildSearchTypeButton('medicineTab'.tr(context), provider.isMedicineSearch,
                      isDark, () => provider.toggleSearchType(true)),
                  const SizedBox(width: 10),
                  _buildSearchTypeButton('pharmacyTab'.tr(context), !provider.isMedicineSearch,
                      isDark, () => provider.toggleSearchType(false)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTypeButton(
      String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? _brandGreen
                : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
                color: isSelected
                    ? _brandGreen
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey.shade300 : Colors.black87),
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsBottomSheet(MapProvider provider, bool isDark) {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, -5))
            ],
          ),
          child: Column(
            children: [
              Center(
                  child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)))),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${provider.pharmacies.length} ${'resultsFound'.tr(context)}",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.sort, color: _brandGreen),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 4,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: AppShimmer(width: double.infinity, height: 110),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.pharmacies.length,
                        itemBuilder: (context, index) {
                          final pharmacy = provider.pharmacies[index];
                          return PharmacyCard(
                            item: pharmacy,
                            isMapMode: !(provider.isMedicineSearch &&
                                provider.lastQuery.isNotEmpty),
                            isSelected:
                                provider.selectedPharmacyId == pharmacy.id,
                            onTap: () => provider.selectPharmacy(pharmacy.id),
                            onGoTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PharmacyScreen(
                                  pharmacyId: pharmacy.id.toString(),
                                  pharmacyName: pharmacy.name,
                                  doctorName: pharmacy.name,
                                ),
                              ),
                            ),
                            onNotify: () => provider.notifyApi(pharmacy.id),
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "${'addedToCart'.tr(context)} ${provider.lastQuery.isEmpty ? "" : provider.lastQuery} ${pharmacy.name}"),
                                  backgroundColor: const Color(0xFF1E824C),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🚀 Dark Mode JSON String لخرائط جوجل
const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1b1b1b"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]
''';
