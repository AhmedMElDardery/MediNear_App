import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/features/auth/presentation/auth_provider.dart';
import 'package:medinear_app/features/home/presentation/provider/home_provider.dart';
import 'package:medinear_app/features/home/presentation/widgets/ads_slider.dart';
import 'package:medinear_app/features/home/presentation/widgets/home_header.dart';
import 'package:medinear_app/features/home/presentation/widgets/medicine_card.dart';
import 'package:medinear_app/features/home/presentation/widgets/pharmacy_card.dart';
import 'package:medinear_app/features/home/presentation/widgets/search_bar.dart';
import 'package:medinear_app/features/pharmacy/presentation/screens/pharmacy_screen.dart';
import 'package:medinear_app/features/profile/view_models/profile_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    Future.microtask(() {
      context.read<HomeProvider>().loadHome();
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning ☀️";
    if (hour < 17) return "Good Afternoon 🌤️";
    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: _buildBody(provider, auth, profile, context),
      ),
      floatingActionButton: _buildFABs(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFABs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 📷 Camera Button
          _CameraFab(
            onTap: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (image != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Photo captured!'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF00965E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          // 🤖 AI Chatbot Button
          _AIChatFab(
            onTap: () => Navigator.pushNamed(context, AppRoutes.chats),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(HomeProvider provider, AuthProvider auth,
      ProfileProvider profile, BuildContext context) {
    // ⏳ Loading
    if (provider.isLoading) {
      return _buildLoadingState();
    }

    // 🔴 Error
    if (provider.errorMessage != null) {
      return _buildErrorState(provider);
    }

    // 🟢 Content — trigger fade in
    if (!_fadeController.isCompleted) {
      _fadeController.forward();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        color: const Color(0xFF00965E),
        onRefresh: () async {
          await provider.loadHome();
          if (context.mounted) {
            await profile.fetchProfile();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const HomeHeader(),

              /// GREETING + USER INFO
              _buildGreetingSection(auth, profile, provider),

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: SearchBarWidget(
                  onSearch: (value) {
                    context.read<HomeProvider>().search(value);
                  },
                ),
              ),

              /// QUICK STATS
              _buildQuickStats(provider),

              /// ADS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: AdsSlider(ads: provider.ads),
              ),

              const SizedBox(height: 24),

              /// NEAR PHARMACIES
              _buildSectionHeader(
                title: "Near Pharmacies",
                icon: Icons.local_pharmacy_rounded,
                count: provider.pharmacies.length,
                onSeeAll: () => Navigator.pushNamed(context, AppRoutes.map),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 175,
                child: provider.filteredPharmacies.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.local_pharmacy_outlined,
                        message: provider.searchQuery.isNotEmpty
                            ? 'No pharmacies match "${provider.searchQuery}"'
                            : "No pharmacies found nearby",
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.filteredPharmacies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final pharmacy = provider.filteredPharmacies[index];
                          return PharmacyCard(
                            pharmacy: pharmacy,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PharmacyScreen(
                                  pharmacyId: pharmacy.id
                                      .toString(), // 🚀 ضفنا الـ ID بتاع الصيدلية هنا
                                  pharmacyName: pharmacy.name,
                                  doctorName: pharmacy
                                      .name, // زي ما هي مكتوبة عندك في الكود
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 24),

              /// NEAR MEDICINES
              _buildSectionHeader(
                title: "Near Medicines",
                icon: Icons.medication_rounded,
                count: provider.medicines.length,
                onSeeAll: () => Navigator.pushNamed(context, AppRoutes.map),
              ),

              const SizedBox(height: 12),

              /// MEDICINES LIST
              SizedBox(
                height: 210,
                child: provider.filteredMedicines.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.medication_outlined,
                        message: provider.searchQuery.isNotEmpty
                            ? 'No medicines match "${provider.searchQuery}"'
                            : "No medicines found nearby",
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.filteredMedicines.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => MedicineCard(
                            medicine: provider.filteredMedicines[index]),
                      ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(
      AuthProvider auth, ProfileProvider profile, HomeProvider provider) {
    // الاسم الكامل: من البروفايل أولاً، وإلا من الأوث
    final fullName = profile.user?.name ?? auth.currentUser?.name ?? "User";

    // الصورة: من البروفايل أولاً (photoUrl أو avatar)، وإلا من الأوث
    final photoUrl = profile.user?.photoUrl ??
        profile.user?.avatar ??
        auth.currentUser?.imageUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Avatar with border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00965E).withOpacity(0.3),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00965E).withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF00965E),
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Text(
                      fullName.isNotEmpty
                          ? fullName.substring(0, 1).toUpperCase()
                          : "U",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                if (provider.currentLocation != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Color(0xFF00965E)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          provider.currentLocationName ?? "Locating...",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF888888),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.local_pharmacy_rounded,
            label: "${provider.pharmacies.length} Pharmacies",
            color: const Color(0xFF00965E),
            bgColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF00965E).withOpacity(0.15) : const Color(0xFFE8F5EE),
          ),
          const SizedBox(width: 10),
          _StatChip(
            icon: Icons.medication_rounded,
            label: "${provider.medicines.length} Medicines",
            color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : const Color(0xFF1565C0),
            bgColor: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withOpacity(0.15) : const Color(0xFFE3F0FF),
          ),
          const SizedBox(width: 10),
          _StatChip(
            icon: Icons.near_me_rounded,
            label: "Nearby",
            color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade300 : const Color(0xFFE65100),
            bgColor: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withOpacity(0.15) : const Color(0xFFFFF3E0),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int count,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00965E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF00965E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00965E).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00965E).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00965E),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: Color(0xFF00965E)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, 
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: const Color(0xFF00965E).withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Color(0xFF00965E),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Finding pharmacies near you...",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade200 : const Color(0xFF555555),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Getting your location 📍",
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(HomeProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.location_off_rounded,
                  size: 52, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              provider.errorMessage ??
                  "Unable to fetch data. Please try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF777777),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => provider.loadHome(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  "Try Again",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00965E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: const Color(0xFF00965E).withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 🤖 AI Chatbot FAB
// ─────────────────────────────────────────
class _AIChatFab extends StatefulWidget {
  final VoidCallback onTap;
  const _AIChatFab({required this.onTap});

  @override
  State<_AIChatFab> createState() => _AIChatFabState();
}

class _AIChatFabState extends State<_AIChatFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _glowAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 6, end: 18).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.chatbot);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00D68F), Color(0xFF00965E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00965E).withOpacity(0.5),
                  blurRadius: _glowAnim.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child:  Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 📷 Camera FAB
// ─────────────────────────────────────────
class _CameraFab extends StatefulWidget {
  final VoidCallback onTap;
  const _CameraFab({required this.onTap});

  @override
  State<_CameraFab> createState() => _CameraFabState();
}

class _CameraFabState extends State<_CameraFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : const Color(0xFF00965E).withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Color(0xFF00965E),
            size: 26,
          ),
        ),
      ),
    );
  }
}
