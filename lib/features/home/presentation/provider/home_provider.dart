import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

import 'package:medinear_app/features/home/domain/entities/ad_entity.dart';
import 'package:medinear_app/features/home/domain/entities/medicine_entity.dart';
import 'package:medinear_app/features/home/domain/entities/pharmacy_entity.dart';
import 'package:medinear_app/features/home/domain/repositories/home_repository.dart';
import 'package:medinear_app/core/services/location_service.dart';
import 'package:medinear_app/core/services/token_storage.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository repository;
  HomeProvider(this.repository);

  List<AdEntity> ads = [];
  List<PharmacyEntity> pharmacies = [];
  List<MedicineEntity> medicines = [];

  // 🔍 Search
  String searchQuery = '';
  List<PharmacyEntity> get filteredPharmacies {
    if (searchQuery.isEmpty) return pharmacies;
    final q = searchQuery.toLowerCase();
    return pharmacies
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  List<MedicineEntity> get filteredMedicines {
    if (searchQuery.isEmpty) return medicines;
    final q = searchQuery.toLowerCase();
    return medicines.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  void search(String query) {
    searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    notifyListeners();
  }

  bool isLoading = true;
  String? errorMessage;
  Position? currentLocation;
  String? currentLocationName;

  Future<void> loadHome() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ⚡️ ابدأ جلب الإعلانات فوراً بالتوازي وماتستناش اللوكيشن!
      Future<void> fetchAds = repository
          .getAds()
          .then((value) => ads = value)
          .catchError((_) => ads = []);

      // 1️⃣ جيب اللوكيشن
      currentLocation = await LocationService.getCurrentLocation();

      // 🆕 ابعت اللوكيشن للباك إند (شغله في الخلفية عشان ميعطلش الشاشة)
      if (currentLocation != null) {
        _sendLocationToServer(
            currentLocation!.latitude, currentLocation!.longitude);
      }

      // 2️⃣ حوّل الإحداثيات لاسم مكان مقروء بدون ما نأخر باقي الصفحة
      if (currentLocation != null) {
        _reverseGeocode(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ).then((name) {
          if (name != null) {
            currentLocationName = name;
            notifyListeners();
          }
        });
      }

      Future<void> fetchPharmacies = Future.value();
      Future<void> fetchMedicines = Future.value();

      if (currentLocation != null) {
        // ندى السيرفر فرصة صغيرة يحفظ اللوكيشن قبل ما نقلب الداتا
        await Future.delayed(const Duration(milliseconds: 300));

        fetchPharmacies = repository
            .getNearbyPharmacies(
              currentLocation!.latitude,
              currentLocation!.longitude,
            )
            .then((value) => pharmacies = value);

        fetchMedicines = repository
            .getNearbyMedicines(
              currentLocation!.latitude,
              currentLocation!.longitude,
            )
            .then((value) => medicines = value);
      }

      // استنى الإعلانات والصيدليات والأدوية تخلص
      await Future.wait([fetchAds, fetchPharmacies, fetchMedicines]);

      isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      isLoading = false;
      final errorMsg = e.response?.data?['message'] ??
          e.response?.data?.toString() ??
          e.message;
      errorMessage = "Server Error: $errorMsg";
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  /// Reverse geocoding باستخدام Nominatim (OpenStreetMap) — مجاني بدون API key
  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'User-Agent': 'MediNearApp/1.0'},
      ));

      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'accept-language': 'en',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['address'];
        if (address != null) {
          // نجيب أقرب تفصيل مهم: الحي ثم المدينة ثم الدولة
          final suburb = address['suburb'] ??
              address['neighbourhood'] ??
              address['quarter'];
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'];
          final country = address['country'];

          if (suburb != null && city != null) {
            return "$suburb, $city";
          } else if (city != null) {
            return country != null ? "$city, $country" : city;
          } else if (country != null) {
            return country;
          }
        }

        // fallback: الاسم الكامل
        return response.data['display_name']
            ?.toString()
            .split(',')
            .take(2)
            .join(',')
            .trim();
      }
    } catch (_) {
      // لو فشل الـ reverse geocoding نرجع null بهدوء
    }
    return null;
  }

  // 🆕 ابعت اللوكيشن للسيرفر عشان يتحفظ في بروفايل اليوزر
  Future<void> _sendLocationToServer(double lat, double lng) async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final formData = FormData.fromMap({
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'lat': lat.toString(),
        'lng': lng.toString(),
      });

      final response = await dio.post(
        'https://medinear-eg.com/api/profile/location',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      debugPrint("✅ HomeProvider: Location Update Response: ${response.data}");
    } catch (e) {
      debugPrint("⚠️ HomeProvider: Failed to send location: $e");
    }
  }
}
