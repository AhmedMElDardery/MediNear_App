import 'package:flutter/material.dart';
// مسارات نسبية
import '../../data/datasources/checkout_remote_data_source.dart';
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

  Future<bool> confirmOrder(
      double totalAmount, List<CartItemModel> cartItems) async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final orderData = {
      'name': nameController.text,
      'phone': '${_selectedCountry['code']} ${phoneController.text}',
      'address': addressController.text,
      'total': totalAmount,
      'items': cartItems.map((e) => e.toJson()).toList(),
    };

    bool isSuccess = await _dataSource.placeOrder(orderData);

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
