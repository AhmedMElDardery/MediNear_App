import 'package:flutter/material.dart';
import 'package:medinear_app/core/provider/navigation_provider.dart';
import 'package:medinear_app/core/widgets/buttom_navbar.dart';
import 'package:medinear_app/core/widgets/home_floating_button.dart';
import 'package:medinear_app/features/cart/presentation/screens/cart_pharmacies_screen.dart';
import 'package:medinear_app/features/home/presentation/screens/home_screen.dart';
import 'package:medinear_app/features/map/presentation/screens/map_screen.dart';
import 'package:medinear_app/features/profile/views/profile_screen.dart';
import 'package:medinear_app/features/saved_items/presentation/screens/saved_items_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';

class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);

    final pages = [
      const HomeScreen(),
      const CartPharmaciesScreen(),
      const SavedItemsScreen(),
      const MapScreen(medicine: ""),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset:
          false, // يمنع البار السفلي والزر العائم من الارتفاع أعلى الكيبورد
      body: IndexedStack(
        index: nav.currentIndex,
        children: pages,
      ),
      floatingActionButton: const HomeFloatingButton(),
      floatingActionButtonLocation: const FixedCenterDockedFabLocation(),
      bottomNavigationBar: const CustomBottomNavBar(),
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
