import 'package:flutter/material.dart';
// مسارات نسبية
import '../../data/datasources/checkout_remote_data_source.dart';
import '../../data/models/checkout_summary_model.dart';
import '../../../cart/data/models/cart_item_model.dart';

class CheckoutProvider extends ChangeNotifier {
  final CheckoutRemoteDataSource _dataSource = CheckoutRemoteDataSource();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final List<Map<String, dynamic>> countries = [
    {'name': 'Egypt', 'flag': '🇪🇬', 'code': '+20', 'maxLength': 11},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': '+966', 'maxLength': 9},
    {'name': 'UAE', 'flag': '🇦🇪', 'code': '+971', 'maxLength': 9},
    {'name': 'Kuwait', 'flag': '🇰🇼', 'code': '+965', 'maxLength': 8},
  ];

  late Map<String, dynamic> _selectedCountry;
  
  CheckoutSummaryModel? summary;
  bool isLoadingSummary = false;
  bool isApplyingCoupon = false;
  String paymentMethod = 'cash'; // 'cash' or 'paymob'

  CheckoutProvider() {
    _selectedCountry = countries[0];
  }

  Map<String, dynamic> get selectedCountry => _selectedCountry;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void changeCountry(Map<String, dynamic> newCountry) {
    _selectedCountry = newCountry;
    phoneController.clear();
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  Future<void> fetchSummary() async {
    isLoadingSummary = true;
    notifyListeners();

    summary = await _dataSource.getCheckoutSummary();

    isLoadingSummary = false;
    notifyListeners();
  }

  Future<void> applyCoupon(String code) async {
    if (code.isEmpty) return;
    
    isApplyingCoupon = true;
    notifyListeners();

    final couponResult = await _dataSource.applyCoupon(code);
    if (couponResult != null) {
      // update the summary with the new numbers from coupon
      summary = CheckoutSummaryModel(
        pharmacyId: summary?.pharmacyId,
        totalItems: summary?.totalItems,
        subTotal: couponResult.newSubtotal ?? couponResult.subTotal,
        deliveryFee: couponResult.deliveryFee,
        taxAmount: couponResult.taxAmount,
        grandTotal: couponResult.grandTotal,
        couponCode: couponResult.couponCode,
        couponTitle: couponResult.couponTitle,
        originalSubtotal: couponResult.originalSubtotal,
        discountAmount: couponResult.discountAmount,
        newSubtotal: couponResult.newSubtotal,
      );
    }

    isApplyingCoupon = false;
    notifyListeners();
  }

  Future<String?> confirmOrder(List<CartItemModel> cartItems, int pharmacyId) async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      return "empty_fields";
    }

    _isLoading = true;
    notifyListeners();

    final orderData = {
      'pharmacy_id': pharmacyId,
      'name': nameController.text,
      'phone': phoneController.text, // Sending raw phone number without country code
      'address': addressController.text,
      'payment_method': paymentMethod,
    };

    final result = await _dataSource.placeOrder(orderData);

    _isLoading = false;
    notifyListeners();

    if (result['success'] == true) {
      return result['payment_url'] ?? "cash_success";
    }
    return "error:${result['message'] ?? 'Unknown API error'}";
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
