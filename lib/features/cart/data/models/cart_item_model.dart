class CartMedicineInfo {
  final int id;
  final String name;
  final double officialPrice;
  final String? image;

  CartMedicineInfo({
    required this.id,
    required this.name,
    required this.officialPrice,
    this.image,
  });

  factory CartMedicineInfo.fromJson(Map<String, dynamic> json) {
    return CartMedicineInfo(
      id: json['id'] ?? json['medicine_id'] ?? 0,
      name: json['name'] ?? json['medicine_name'] ?? 'Medicine',
      officialPrice: double.tryParse((json['official_price'] ?? '0').toString()) ?? 0.0,
      image: json['image'] ?? json['medicine_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'official_price': officialPrice.toString(),
      'image': image,
    };
  }
}

class CartItemModel {
  final int cartItemId;
  int quantity;
  final double unitPrice;
  final double itemTotal;
  final CartMedicineInfo medicine;

  CartItemModel({
    required this.cartItemId,
    required this.quantity,
    required this.unitPrice,
    required this.itemTotal,
    required this.medicine,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['id'] ?? json['cart_item_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse((json['price'] ?? json['unit_price'] ?? '0').toString()) ?? 0.0,
      itemTotal: double.tryParse((json['total'] ?? json['item_total'] ?? '0').toString()) ?? 0.0,
      medicine: CartMedicineInfo.fromJson(json['medicine'] ?? json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item_id': cartItemId,
      'quantity': quantity,
      'unit_price': unitPrice.toString(),
      'item_total': itemTotal.toString(),
      'medicine': medicine.toJson(),
    };
  }
}
