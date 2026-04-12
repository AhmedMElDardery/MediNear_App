import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/datasources/order_remote_data_source.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRemoteDataSource _dataSource = OrderRemoteDataSource();
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
   
    if (_orders.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();
    
    try {
      _orders = await _dataSource.getOrders();
    } catch (e) {
      debugPrint("Order Error: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
}