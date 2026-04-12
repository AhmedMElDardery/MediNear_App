import '../entities/pharmacy_entity.dart';
import '../entities/medicine_entity.dart';
import '../entities/recent_search_entity.dart';

abstract class MapRepository {
  Future<List<PharmacyEntity>> searchMedicine({
    double? lat,
    double? lng,
    required String medicine,
    required bool isMedicineSearch,
  });

  Future<List<PharmacyEntity>> getAllPharmacies({double? lat, double? lng});
  Future<void> notifyMe(String pharmacyId);
  Future<List<MedicineEntity>> getMedicines();
  Future<List<RecentSearchEntity>> getRecentSearches();
  Future<void> updateUserLocation({required double lat, required double lng}); // 🆕
}