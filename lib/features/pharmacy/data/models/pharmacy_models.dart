class PharmacyMedicineModel {
  final int id;
  final String name;
  final double oldPrice;
  final double price;
  final int discount;
  final double rating;
  final bool inStock;
  final String image;
  bool notifyAvailable;
  bool isSaved;

  PharmacyMedicineModel({
    required this.id,
    required this.name,
    required this.oldPrice,
    required this.price,
    required this.discount,
    required this.rating,
    required this.inStock,
    required this.image,
    this.notifyAvailable = false,
    this.isSaved = false,
  });

  factory PharmacyMedicineModel.fromJson(Map<String, dynamic> json) {
    return PharmacyMedicineModel(
      id: json['id'] ?? json['medicine_id'] ?? 0,
      name: json['name'] ?? '',
      oldPrice: (json['oldPrice'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      discount: json['discount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      inStock: json['inStock'] ?? (json['status'] == 'available') ?? true,
      image: json['image'] ?? '',
      notifyAvailable: json['notifyAvailable'] ?? false,
      isSaved: json['isSaved'] ?? json['is_saved'] ?? false,
    );
  }
}

class PharmacyDoctorModel {
  final int id;
  final String name;
  final String specialty;
  final double rating;
  final String? image;
  bool isSaved;

  PharmacyDoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    this.image,
    this.isSaved = false,
  });

  factory PharmacyDoctorModel.fromJson(Map<String, dynamic> json) {
    return PharmacyDoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      image: json['image'],
      isSaved: json['isSaved'] ?? false,
    );
  }
}

class PharmacyServiceModel {
  final int id;
  final String name;
  final double price;
  final String duration;
  final String image;
  bool isSaved;

  PharmacyServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.image,
    this.isSaved = false,
  });

  factory PharmacyServiceModel.fromJson(Map<String, dynamic> json) {
    return PharmacyServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? '',
      image: json['image'] ?? '',
      isSaved: json['isSaved'] ?? false,
    );
  }
}
