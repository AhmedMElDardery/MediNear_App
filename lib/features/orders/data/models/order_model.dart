import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String pharmacyName;
  final String location;
  final String status;
  final String date;
  final List<OrderItemModel> items;

  OrderModel(
      {required this.id,
      required this.pharmacyName,
      required this.location,
      required this.status,
      required this.date,
      required this.items});

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get total => items.fold(0.0, (sum, item) => sum + item.total);

  // � تحويل الـ JSON لموديل كامل
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      pharmacyName: json['pharmacy']?['pharmacy_name'] ?? 'Unknown Pharmacy',
      location: json['address'] ?? json['pharmacy']?['address'] ?? '',
      status: json['status'] ?? '',
      date: json['created_at'] ?? '',
      items: (json['items'] as List?)
          ?.map((i) => OrderItemModel.fromJson(i))
          .toList() ?? [],
    );
  }
}
