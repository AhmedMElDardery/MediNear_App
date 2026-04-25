class CartPharmacyModel {
  final int id;
  final String pharmacyName;
  final String? image;
  final String address;
  final String city;

  CartPharmacyModel({
    required this.id,
    required this.pharmacyName,
    this.image,
    required this.address,
    required this.city,
  });

  factory CartPharmacyModel.fromJson(Map<String, dynamic> json) {
    return CartPharmacyModel(
      id: json['id'] ?? 0,
      pharmacyName: json['pharmacy_name'] ?? '',
      image: json['image'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacy_name': pharmacyName,
      'image': image,
      'address': address,
      'city': city,
    };
  }
}
