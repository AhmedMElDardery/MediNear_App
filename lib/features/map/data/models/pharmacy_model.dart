import '../../domain/entities/pharmacy_entity.dart';

class PharmacyModel extends PharmacyEntity {
  PharmacyModel({
    required super.id,
    required super.name,
    required super.lat,
    required super.lng,
    required super.distance,
    required super.address,
    required super.hasMedicine,
    required super.availabilityStatus,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    // السحر هنا: بنجيب حالة الدواء من الـ object اللي راجع
    final availability = json['medicine_availability'] ?? {};
    final status = availability['status'] ?? 'not_listed';

    return PharmacyModel(
      id: json['id'].toString(),
      name: json['pharmacy_name'] ??
          'صيدلية غير معروفة', // استخدمنا pharmacy_name من الـ API
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      // لو الـ status بـ available، يبقى الدواء موجود، غير كده محتاجين Notify
      hasMedicine: status == 'available',
      availabilityStatus: status,
    );
  }
}
