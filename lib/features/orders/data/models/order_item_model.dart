class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  OrderItemModel(
      {required this.name, required this.quantity, required this.price});

  double get total => price * quantity;

  // 🚀 تحويل الـ JSON لموديل
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
