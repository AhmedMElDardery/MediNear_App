import '../../domain/entities/medicine_entity.dart';

class MedicineModel extends MedicineEntity {
  MedicineModel({required super.id, required super.name, super.categoryName});
  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      categoryName: json['category'] != null
          ? json['category']['name']?.toString()
          : null,
    );
  }
}
