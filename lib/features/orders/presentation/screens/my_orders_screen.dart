import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart'; // � للتعامل مع الـ Provider
import '../../data/models/order_model.dart';
import '../manager/order_provider.dart'; // � استدعاء المدير
import '../widgets/order_card.dart';
import 'order_details_screen.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  String _searchText = "";
  String _selectedStatus = "All";
  String _selectedPharmacy = "All";

  @override
  void initState() {
    super.initState();
    //  طلب جلب البيانات أول ما الشاشة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(orderProvider).fetchOrders();
    });
  }

  //  دالة الفلترة الذكية (بتطبق على الداتا اللي جاية من البروفايدر)
  List<OrderModel> _getFilteredOrders(List<OrderModel> allOrders) {
    return allOrders.where((order) {
      final matchesSearch = order.pharmacyName
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          order.id.contains(_searchText);
      final matchesStatus =
          _selectedStatus == "All" || order.status.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesPharmacy =
          _selectedPharmacy == "All" || order.pharmacyName == _selectedPharmacy;
      return matchesSearch && matchesStatus && matchesPharmacy;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.translate("myOrders"),
      ),
      // � استخدام Consumer لمراقبة حالة الطلبات
      body: Consumer(
        builder: (context, ref, child) {
          final provider = ref.watch(orderProvider);
          // جلب القائمة المفلترة
          final filteredOrders = _getFilteredOrders(provider.orders);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. خانة البحث
                TextField(
                  onChanged: (value) => setState(() => _searchText = value),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.translate("searchOrders"),
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. فلاتر الحالة (Tabs) و الصيدلية (Icon Filter)
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusTab("All",
                                AppLocalizations.of(context)!.translate("all")),
                            _buildStatusTab(
                                "Pending",
                                AppLocalizations.of(context)!
                                    .translate("pending")),
                            _buildStatusTab(
                                "Completed",
                                AppLocalizations.of(context)!
                                    .translate("completed")),
                            _buildStatusTab(
                                "Canceled",
                                AppLocalizations.of(context)!
                                    .translate("canceled")),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Pharmacy Filter as a cool circular button
                    PopupMenuButton<String>(
                      onSelected: (val) =>
                          setState(() => _selectedPharmacy = val),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      itemBuilder: (context) =>
                          ["All", "MediNear", "El-Ezaby", "Seif Pharmacy"]
                              .map((choice) => PopupMenuItem(
                                    value: choice,
                                    child: Text(choice == "All"
                                        ? AppLocalizations.of(context)!
                                            .translate("all")
                                        : choice),
                                  ))
                              .toList(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.filter_list,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 3. عرض النتائج أو حالة التحميل
                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary))
                      : filteredOrders.isEmpty
                          ? _buildEmptyState(textColor)
                          : ListView.builder(
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                return OrderCard(
                                  order: filteredOrders[index],
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderDetailsScreen(
                                                    order: filteredOrders[
                                                        index])));
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets مساعدة ---

  Widget _buildStatusTab(String status, String displayTitle) {
    final isSelected = _selectedStatus == status;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor : primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayTitle,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color? textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long,
                size: 60, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.translate("noOrdersFound"),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)?.translate("home") == "الرئيسية"
                ? "لا توجد طلبات سابقة لتظهر هنا."
                : "Looks like you haven't placed any orders yet.",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
