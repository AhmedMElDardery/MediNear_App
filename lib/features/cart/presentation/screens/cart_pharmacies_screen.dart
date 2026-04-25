import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import 'package:medinear_app/features/cart/presentation/manager/cart_provider.dart';
import 'package:medinear_app/core/widgets/app_shimmer.dart';
import 'package:medinear_app/core/widgets/custom_empty_state.dart';
import 'my_cart_screen.dart';

class CartPharmaciesScreen extends ConsumerStatefulWidget {
  const CartPharmaciesScreen({super.key});

  @override
  ConsumerState<CartPharmaciesScreen> createState() =>
      _CartPharmaciesScreenState();
}

class _CartPharmaciesScreenState extends ConsumerState<CartPharmaciesScreen> {
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(cartProvider).loadCartData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Cart",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final provider = ref.watch(cartProvider);
          if (provider.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: AppShimmer(width: double.infinity, height: 90, borderRadius: 16),
              ),
            );
          }

          if (provider.cartItems.isEmpty) {
            return const CustomEmptyState(
              title: "Your Cart is Empty!",
              subtitle: "Looks like you haven't added any items to your cart yet.",
              icon: Icons.shopping_cart_outlined,
            );
          }

          final allPharmacies = provider.uniquePharmacies;

          final filteredPharmacies = allPharmacies.where((name) {
            return name.toLowerCase().contains(_searchText.toLowerCase());
          }).toList();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("Select a Pharmacy",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10)
                    ],
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.primaryLight),
                      suffixIcon: Icon(Icons.filter_list,
                          color: AppColors.primaryLight),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: filteredPharmacies.isEmpty
                    ? Center(
                        child: Text("No pharmacy found!",
                            style: TextStyle(color: textColor)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: filteredPharmacies.length,
                        itemBuilder: (context, index) {
                          final pharmacyName = filteredPharmacies[index];
                          final items =
                              provider.getItemsByPharmacy(pharmacyName);
                          final firstItem = items.first;
                          final itemsCount = items.length;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyCartScreen(pharmacyName: pharmacyName),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5))
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.primaryLight
                                        .withValues(alpha: 0.2),
                                    child: const Icon(Icons.store,
                                        color: AppColors.primaryLight,
                                        size: 28),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(pharmacyName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: textColor)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 14, color: Colors.grey),
                                            Text(firstItem.pharmacyLocation,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D32),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text("$itemsCount Products",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
