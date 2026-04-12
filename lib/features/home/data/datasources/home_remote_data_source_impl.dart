import 'package:dio/dio.dart';
import 'package:medinear_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medinear_app/core/services/token_storage.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  final TokenStorage tokenStorage;

  HomeRemoteDataSourceImpl({required this.dio, required this.tokenStorage});

  // ✅ helper: بيتعامل مع status سواء جه true (bool) أو 1 (int) من الـ API
  bool _isSuccess(dynamic status) {
    if (status == true) return true;
    if (status == 1) return true;
    if (status.toString() == "true") return true;
    return false;
  }

  @override
  Future<List<Map<String, dynamic>>> getAds() async {
    try {
      final response = await dio.get("/pharmacy/ads");

      // 🧪 DEBUG: نشوف الـ response كامل
      print("======= ADS RESPONSE =======");
      print("Status Code: ${response.statusCode}");
      print("Data: ${response.data}");
      print("Data type: ${response.data.runtimeType}");
      print("============================");

      final data = response.data;

      // ✅ Dio بيعمل throw تلقائي لو HTTP مش 200
      // فلو وصلنا هنا يعني الـ response ناجح → نجيب الـ data مباشرة
      if (data is Map && data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Unexpected ads structure: $data");
        return [];
      }
    } catch (e) {
      print("Ads Error: $e");
      throw Exception("Ads Error: $e");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyPharmacies(
      double lat, double lng) async {
    try {
      final token = await tokenStorage.getToken();
      print("Token for Pharmacies: $token");

      final response = await dio.get(
        "/pharmacy/near-pharmacies",
        queryParameters: {
          "page": 1,
          "per_page": 5,
          "latitude": lat,
          "longitude": lng,
          "lat": lat,
          "lng": lng,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "lat": lat.toString(),
            "lng": lng.toString(),
            "latitude": lat.toString(),
            "longitude": lng.toString(),
          },
        ),
      );

      // 🧪 DEBUG
      print("======= PHARMACIES RESPONSE =======");
      print("Data: ${response.data}");
      print("===================================");

      final data = response.data;

      // ✅ نعتمد على HTTP 200 مش على status field
      if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is Map && inner.containsKey('data')) {
          return List<Map<String, dynamic>>.from(inner['data']);
        } else if (inner is List) {
          return List<Map<String, dynamic>>.from(inner);
        }
      }
      return [];
    } catch (e) {
      throw Exception("Pharmacy Error: $e");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyMedicines(
      double lat, double lng) async {
    try {
      final token = await tokenStorage.getToken();

      final response = await dio.get(
        "/pharmacy/near-medicines",
        queryParameters: {
          "page": 1,
          "per_page": 5,
          "latitude": lat,
          "longitude": lng,
          "lat": lat,
          "lng": lng,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "lat": lat.toString(),
            "lng": lng.toString(),
            "latitude": lat.toString(),
            "longitude": lng.toString(),
          },
        ),
      );

      // 🧪 DEBUG
      print("======= MEDICINES RESPONSE =======");
      print("Data: ${response.data}");
      print("==================================");

      final data = response.data;

      // ✅ نعتمد على HTTP 200 مش على status field
      if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is Map && inner.containsKey('data')) {
          return List<Map<String, dynamic>>.from(inner['data']);
        } else if (inner is List) {
          return List<Map<String, dynamic>>.from(inner);
        }
      }
      return [];
    } catch (e) {
      throw Exception("Medicines API Error: $e");
    }
  }
}