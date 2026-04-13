class SavedPharmacyModel {
  final String id;
  final String name;
  final String location;
  final String image;
  final String productsCount;
  bool isSaved;

  SavedPharmacyModel({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.productsCount,
    this.isSaved = true,
  });

  factory SavedPharmacyModel.fromJson(Map<String, dynamic> json) {
    return SavedPharmacyModel(
      id: json['id']?.toString() ?? json['name'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      productsCount: json['products'] ?? '0 Products',
      isSaved: json['isSaved'] ?? true,
    );
  }
}

class SavedMedicationModel {
  final String id;
  final String name;
  final String price;
  final String image;
  final bool isAvailable;
  bool isSaved;

  SavedMedicationModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.isAvailable,
    this.isSaved = true,
  });

  factory SavedMedicationModel.fromJson(Map<String, dynamic> json) {
    return SavedMedicationModel(
      id: json['id']?.toString() ?? json['name'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '0 EGP',
      image: json['image'] ?? '',
      isAvailable: json['available'] ?? false,
      isSaved: json['isSaved'] ?? true,
    );
  }
}