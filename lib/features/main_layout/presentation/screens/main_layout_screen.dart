import 'package:flutter/material.dart';

import 'package:medinear_app/core/widgets/buttom_navbar.dart';
import 'package:medinear_app/core/widgets/home_floating_button.dart';
import 'package:medinear_app/features/cart/presentation/screens/cart_pharmacies_screen.dart';
import 'package:medinear_app/features/home/presentation/screens/home_screen.dart';
import 'package:medinear_app/features/map/presentation/screens/map_screen.dart';
import 'package:medinear_app/features/profile/views/profile_screen.dart';
import 'package:medinear_app/features/saved_items/presentation/screens/saved_items_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';

import 'package:flutter/services.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    final nav = ref.watch(navigationProvider);

    final pages = [
      const HomeScreen(),
      const CartPharmaciesScreen(),
      const SavedItemsScreen(),
      const MapScreen(medicine: ""),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Optional: if not on Home tab, return to Home tab first
        if (nav.currentIndex != 0) {
          ref.read(navigationProvider).changeIndex(0);
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 50, left: 40, right: 40),
              padding: EdgeInsets.zero,
              duration: const Duration(seconds: 2),
              content: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'اضغط مرة أخرى للخروج',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false, // يمنع البار السفلي والزر العائم من الارتفاع أعلى الكيبورد
        body: IndexedStack(
          index: nav.currentIndex,
          children: pages,
        ),
        floatingActionButton: const HomeFloatingButton(),
        floatingActionButtonLocation: const FixedCenterDockedFabLocation(),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}

class FixedCenterDockedFabLocation extends FloatingActionButtonLocation {
  const FixedCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
    
    // Standard dock Y calculation without subtracting SnackBar height
    final double fabY = scaffoldGeometry.contentBottom - (scaffoldGeometry.floatingActionButtonSize.height / 2.0);
    
    return Offset(fabX, fabY);
  }
}
