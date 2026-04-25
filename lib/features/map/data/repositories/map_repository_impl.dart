import 'package:medinear_app/features/map/data/datasource/map_remote_datasource.dart';
import '../models/pharmacy_model.dart';
import '../models/medicine_model.dart';
import '../models/recent_search_model.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/entities/recent_search_entity.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remote;

  MapRepositoryImpl(this.remote);

  @override
  Future<List<PharmacyEntity>> searchMedicine({
    double? lat,
    double? lng,
    required String medicine,
    required bool isMedicineSearch,
  }) async {
    final isId = int.tryParse(medicine) != null;

    final data = await remote.search(
      type: isMedicineSearch ? 'medicine' : 'pharmacy',
      medicineId: (isMedicineSearch && isId) ? medicine : null,
      query: (!isId || !isMedicineSearch) ? medicine : null,
      lat: lat,
      lng: lng,
    );

    return data.map<PharmacyEntity>((e) => PharmacyModel.fromJson(e)).toList();
  }

  @override
  Future<List<PharmacyEntity>> getAllPharmacies(
      {double? lat, double? lng}) async {
    final data = await remote.getAllPharmacies(lat: lat, lng: lng);
    return data.map<PharmacyEntity>((e) => PharmacyModel.fromJson(e)).toList();
  }

  @override
  Future<void> notifyMe(String pharmacyId) {
    return remote.notifyMe(pharmacyId);
  }

  @override
  Future<List<MedicineEntity>> getMedicines() async {
    final data = await remote.getMedicines();
    return data.map<MedicineEntity>((e) => MedicineModel.fromJson(e)).toList();
  }

  @override
  Future<List<RecentSearchEntity>> getRecentSearches() async {
    final data = await remote.getRecentSearches();
    return data
        .map<RecentSearchEntity>((e) => RecentSearchModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> updateUserLocation({required double lat, required double lng}) {
    return remote.updateUserLocation(lat: lat, lng: lng);
  }
}
