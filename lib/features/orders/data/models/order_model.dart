import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String pharmacyName;
  final String location;
  final String status;
  final String date;
  final List<OrderItemModel> items;

  OrderModel({required this.id, required this.pharmacyName, required this.location, required this.status, required this.date, required this.items});

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get total => items.fold(0.0, (sum, item) => sum + item.total);

  // 🚀 تحويل الـ JSON لموديل كامل
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      items: (json['items'] as List).map((i) => OrderItemModel.fromJson(i)).toList(),
    );
  }
}