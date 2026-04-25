import 'cart_item_model.dart';

class CartPharmacyDetailsModel {
  final int pharmacyId;
  final int totalItems;
  final double totalPrice;
  final List<CartItemModel> items;

  CartPharmacyDetailsModel({
    required this.pharmacyId,
    required this.totalItems,
    required this.totalPrice,
    required this.items,
  });

  factory CartPharmacyDetailsModel.fromJson(Map<String, dynamic> json) {
    return CartPharmacyDetailsModel(
      pharmacyId: json['pharmacy_id'] ?? 0,
      totalItems: json['total_items'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => CartItemModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pharmacy_id': pharmacyId,
      'total_items': totalItems,
      'total_price': totalPrice,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
