import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/provider/navigation_provider.dart';
import 'bouncing_icon_button.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationProvider);
    final selectedIndex = ref.watch(navigationProvider).currentIndex;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      height: 75,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      shadowColor: isDark ? Colors.black : Colors.black45,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Absorb taps
        child: Row(
          children: [
            Expanded(child: _buildNavItem(context, Icons.bookmark_border_rounded, "Saved", 2, isDark, selectedIndex, nav)),
            Expanded(child: _buildNavItem(context, Icons.shopping_cart_outlined, "Cart", 1, isDark, selectedIndex, nav)),
            const SizedBox(width: 70), // Leave space for the center FAB
            Expanded(child: _buildNavItem(context, Icons.map_outlined, "Map", 3, isDark, selectedIndex, nav)),
            Expanded(child: _buildNavItem(context, Icons.person_outline_rounded, "Profile", 4, isDark, selectedIndex, nav)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    bool isDark,
    int selectedIndex,
    NavigationProvider nav,
  ) {
    final bool isSelected = selectedIndex == index;

    const Color mainGreen = Color(0xFF00965E);

    return BouncingIconButton(
      onTap: () => nav.changeIndex(index),
      child: Container(
        color: Colors.transparent,
        height: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16.0 : 8.0,
                vertical: isSelected ? 6.0 : 6.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? mainGreen.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? mainGreen
                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? mainGreen
                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
