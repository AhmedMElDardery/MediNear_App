class CartItemModel {
  final String id;
  final String name;
  final double price;
  int quantity;
  final bool isAvailable;
  
  // 🚀 الإضافات الجديدة
  final String pharmacyName;
  final String pharmacyLocation;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.isAvailable = true,
    required this.pharmacyName,
    required this.pharmacyLocation,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      isAvailable: json['isAvailable'] ?? true,
      pharmacyName: json['pharmacyName'] ?? 'Unknown Pharmacy',
      pharmacyLocation: json['pharmacyLocation'] ?? 'Unknown Location',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'pharmacyName': pharmacyName,
      'pharmacyLocation': pharmacyLocation,
    };
  }

  double get totalPrice => price * quantity;
}