import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_pharmacy_model.dart';
import '../../data/models/cart_pharmacy_details_model.dart';
import '../../data/datasources/cart_remote_data_source.dart';

class CartProvider extends ChangeNotifier {
  final CartRemoteDataSource _dataSource = CartRemoteDataSource();
  
  List<CartPharmacyModel> _cartPharmacies = [];
  bool _isLoadingPharmacies = false;

  CartPharmacyDetailsModel? _currentPharmacyDetails;
  bool _isLoadingPharmacyItems = false;

  List<CartPharmacyModel> get cartPharmacies => _cartPharmacies;
  bool get isLoadingPharmacies => _isLoadingPharmacies;

  CartPharmacyDetailsModel? get currentPharmacyDetails => _currentPharmacyDetails;
  bool get isLoadingPharmacyItems => _isLoadingPharmacyItems;

  Future<void> loadCartPharmacies() async {
    _isLoadingPharmacies = true;
    notifyListeners();
    try {
      _cartPharmacies = await _dataSource.getCartPharmacies();
    } catch (e) {
      debugPrint("Error loading cart pharmacies: $e");
    }
    _isLoadingPharmacies = false;
    notifyListeners();
  }

  Future<void> loadPharmacyItems(int pharmacyId) async {
    _isLoadingPharmacyItems = true;
    _currentPharmacyDetails = null;
    notifyListeners();
    try {
      _currentPharmacyDetails = await _dataSource.getPharmacyCartItems(pharmacyId);
    } catch (e) {
      debugPrint("Error loading pharmacy items: $e");
    }
    _isLoadingPharmacyItems = false;
    notifyListeners();
  }

  Future<void> incrementQuantity(CartItemModel item) async {
    if (_currentPharmacyDetails == null) return;
    int pharmacyId = _currentPharmacyDetails!.pharmacyId;
    
    item.quantity++;
    _recalculateTotal();
    notifyListeners();
    
    bool success = await _dataSource.toggleCartItem(
      medicineId: item.medicine.id,
      pharmacyId: pharmacyId,
      quantity: item.quantity,
    );
    
    if (!success) {
      item.quantity--;
      _recalculateTotal();
      notifyListeners();
      debugPrint("Failed to increment quantity on server");
    }
  }

  Future<void> decrementQuantity(CartItemModel item) async {
    if (_currentPharmacyDetails == null) return;
    if (item.quantity > 1) {
      int pharmacyId = _currentPharmacyDetails!.pharmacyId;
      
      item.quantity--;
      _recalculateTotal();
      notifyListeners();
      
      bool success = await _dataSource.toggleCartItem(
        medicineId: item.medicine.id,
        pharmacyId: pharmacyId,
        quantity: item.quantity,
      );
      
      if (!success) {
        item.quantity++;
        _recalculateTotal();
        notifyListeners();
        debugPrint("Failed to decrement quantity on server");
      }
    }
  }

  Future<void> deleteItem(CartItemModel item) async {
    if (_currentPharmacyDetails == null) return;
    int pharmacyId = _currentPharmacyDetails!.pharmacyId;
    
    final oldItems = List<CartItemModel>.from(_currentPharmacyDetails!.items);
    _currentPharmacyDetails!.items.removeWhere((e) => e.cartItemId == item.cartItemId);
    _recalculateTotal();
    notifyListeners();
    
    bool success = await _dataSource.toggleCartItem(
      medicineId: item.medicine.id,
      pharmacyId: pharmacyId,
    );
    
    if (!success) {
      _currentPharmacyDetails = CartPharmacyDetailsModel(
        pharmacyId: _currentPharmacyDetails!.pharmacyId,
        totalItems: _currentPharmacyDetails!.totalItems,
        totalPrice: _currentPharmacyDetails!.totalPrice,
        items: oldItems,
      );
      _recalculateTotal();
      notifyListeners();
      debugPrint("Failed to delete item on server");
    } else {
        if (_currentPharmacyDetails!.items.isEmpty) {
            // Refresh pharmacies list if cart is now empty
            loadCartPharmacies();
        }
    }
  }

  void _recalculateTotal() {
    if (_currentPharmacyDetails == null) return;
    double total = 0.0;
    int totalItems = 0;
    for (var item in _currentPharmacyDetails!.items) {
      total += (item.unitPrice * item.quantity);
      totalItems++;
    }
    _currentPharmacyDetails = CartPharmacyDetailsModel(
      pharmacyId: _currentPharmacyDetails!.pharmacyId,
      totalItems: totalItems,
      totalPrice: total,
      items: _currentPharmacyDetails!.items,
    );
  }
}
