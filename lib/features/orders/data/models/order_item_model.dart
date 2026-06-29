class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  OrderItemModel(
      {required this.name, required this.quantity, required this.price});

  double get total => price * quantity;

  // � تحويل الـ JSON لموديل
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['medicine']?['name'] ?? 'Unknown Medicine',
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
