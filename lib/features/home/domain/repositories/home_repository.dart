import 'package:medinear_app/features/home/domain/entities/ad_entity.dart';
import 'package:medinear_app/features/home/domain/entities/medicine_entity.dart';
import 'package:medinear_app/features/home/domain/entities/pharmacy_entity.dart';

abstract class HomeRepository {
  Future<List<AdEntity>> getAds();

  // 🚀 ضفنا خط الطول (lng) وخط العرض (lat) عشان الباك إند يعرف إحنا فين
  Future<List<PharmacyEntity>> getNearbyPharmacies(double lat, double lng);

  // 🚀 نفس الكلام للأدوية عشان يجيب المتاح حوالينا بس
  Future<List<MedicineEntity>> getNearbyMedicines(double lat, double lng);
}
