import 'package:flutter/material.dart';
import 'package:medinear_app/features/cart/data/models/cart_item_model.dart';
import 'package:medinear_app/features/cart/data/datasources/cart_remote_data_source.dart';

class CartProvider extends ChangeNotifier {
  final CartRemoteDataSource _dataSource = CartRemoteDataSource();
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  // 🚀 1. جلب أسماء الصيدليات الفريدة
  List<String> get uniquePharmacies {
    return _cartItems.map((item) => item.pharmacyName).toSet().toList();
  }

  // 🚀 2. جلب منتجات صيدلية معينة
  List<CartItemModel> getItemsByPharmacy(String pharmacyName) {
    return _cartItems
        .where((item) => item.pharmacyName == pharmacyName)
        .toList();
  }

  // 🚀 3. حساب التوتال لصيدلية معينة
  double getPharmacyTotal(String pharmacyName) {
    return getItemsByPharmacy(pharmacyName)
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  // 🚀 4. مسح منتجات صيدلية معينة فقط (بعد الدفع)
  void clearCartForPharmacy(String pharmacyName) {
    _cartItems.removeWhere((item) => item.pharmacyName == pharmacyName);
    notifyListeners();
  }

  // الحساب الكلي لكل السلة (لو احتاجناه)
  double get grandTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCartData() async {
    if (_cartItems.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();
    try {
      _cartItems = await _dataSource.getCartItems();
    } catch (e) {
      debugPrint("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  bool incrementQuantity(CartItemModel item) {
    if (item.quantity < 5) {
      item.quantity++;
      notifyListeners();
      return true;
    }
    return false;
  }

  void decrementQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    }
  }

  void deleteItem(CartItemModel item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
