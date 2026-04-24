import 'package:medinear_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medinear_app/features/home/domain/entities/ad_entity.dart';
import 'package:medinear_app/features/home/domain/entities/medicine_entity.dart';
import 'package:medinear_app/features/home/domain/entities/pharmacy_entity.dart';
import 'package:medinear_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<List<AdEntity>> getAds() async {
    final data = await remote.getAds();
    return data.map((e) => AdEntity(
      id: e["id"]?.toString() ?? '',           // ✅ int → String
      imageUrl: e["image"]?.toString() ?? '',   // ✅ null safe
      title: e["title"]?.toString() ?? '',
      redirectUrl: e["link"]?.toString() ?? '',
    )).toList();
  }

  @override
  Future<List<PharmacyEntity>> getNearbyPharmacies(double lat, double lng) async {
    final data = await remote.getNearbyPharmacies(lat, lng);
    return data.map((e) {
      final img = e["logo"]?.toString() ?? 
                  e["image"]?.toString() ?? 
                  e["pharmacy_logo"]?.toString() ?? 
                  e["pharmacy_image"]?.toString();
      final fullImg = (img != null && img.isNotEmpty)
          ? (img.startsWith('http') ? img : 'https://medinear-eg.com/storage/$img')
          : '';

      return PharmacyEntity(
        id: e["id"]?.toString() ?? '',
        name: e["pharmacy_name"]?.toString() ?? 'Unknown',
        image: fullImg,
        address: e['address']?.toString() ?? '',
        phone: e['phone']?.toString(),
        workingHours: e['working_hours']?.toString(),
        distance: e['distance'] != null
            ? "${double.tryParse(e['distance'].toString())?.toStringAsFixed(2) ?? e['distance']} km"
            : null,
      );
    }).toList();
  }

  @override
  Future<List<MedicineEntity>> getNearbyMedicines(double lat, double lng) async {
    final data = await remote.getNearbyMedicines(lat, lng);
    return data.map((e) {
      final img = e["image"]?.toString();
      final fullImg = (img != null && img.isNotEmpty)
          ? (img.startsWith('http') ? img : 'https://medinear-eg.com/storage/$img')
          : '';

      final pivotPrice = e["pivot"] != null ? e["pivot"]["price"]?.toString() : null;
      final officialPrice = e["official_price"]?.toString();
      final finalPriceStr = pivotPrice ?? officialPrice ?? '0';

      return MedicineEntity(
        id: e["id"]?.toString() ?? '',           // ✅ int → String
        name: e["name"]?.toString() ?? 'Unknown',
        imageUrl: fullImg,
        price: num.tryParse(finalPriceStr)?.toDouble() ?? 0.0,
      );
    }).toList();
  }
}