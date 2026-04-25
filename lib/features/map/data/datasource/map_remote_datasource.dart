import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class MapRemoteDataSource {
  final Dio dio;
  MapRemoteDataSource(this.dio);

  Future<List<dynamic>> search({
    required String type,
    String? query,
    String? medicineId,
    double? lat,
    double? lng,
  }) async {
    try {
      // محاولة أولى: مع الـ lat/lng
      final response = await dio.get(
        '/pharmacy/search',
        queryParameters: {
          'type': type,
          if (query != null && query.isNotEmpty) 'q': query,
          if (medicineId != null) 'medicine_id': medicineId,
          if (lat != null) 'latitude': lat,
          if (lng != null) 'longitude': lng,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          'page': 1,
          'per_page': 5,
        },
      );
      return _parseSearchResponse(response);
    } on DioException catch (e) {
      // لو السيرفر رجع 400 بسبب الـ location، نجرب بدونها
      if (e.response?.statusCode == 400) {
        final msg = e.response?.data?['message']?.toString() ?? '';
        debugPrint('Search 400 error: $msg');

        if (msg.toLowerCase().contains('location') ||
            msg.toLowerCase().contains('gps')) {
          debugPrint('Retrying search WITHOUT lat/lng...');
          try {
            final retryResponse = await dio.get(
              '/pharmacy/search',
              queryParameters: {
                'type': type,
                if (query != null && query.isNotEmpty) 'q': query,
                if (medicineId != null) 'medicine_id': medicineId,
                'page': 1,
                'per_page': 5,
              },
            );
            return _parseSearchResponse(retryResponse);
          } catch (retryError) {
            debugPrint('Retry also failed: $retryError');
            return [];
          }
        }
      }
      rethrow;
    }
  }

  List<dynamic> _parseSearchResponse(Response response) {
    debugPrint('==== SEARCH RESPONSE ====');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    debugPrint('=========================');

    final data = response.data['data'];
    if (data is List) return data;
    if (data is Map) {
      if (data['pharmacies'] != null) {
        var targetData = data['pharmacies'];
        if (targetData is List) return targetData;
        if (targetData is Map && targetData['data'] != null)
          return List.from(targetData['data']);
      }
      if (data['data'] != null && data['data'] is List)
        return List.from(data['data']);
      if (data['results'] != null && data['results'] is List)
        return List.from(data['results']);
    }
    return [];
  }

  Future<List<dynamic>> getAllPharmacies({double? lat, double? lng}) async {
    final Map<String, dynamic> queryParameters = {
      'page': 1,
      'per_page': 5,
    };
    if (lat != null) {
      queryParameters['latitude'] = lat;
      queryParameters['lat'] = lat;
    }
    if (lng != null) {
      queryParameters['longitude'] = lng;
      queryParameters['lng'] = lng;
    }

    final response = await dio.get(
      '/pharmacy/near-pharmacies',
      queryParameters: queryParameters,
    );

    var data = response.data['data'];
    if (data is List) return data;
    if (data is Map && data['data'] != null) return data['data'];
    return [];
  }

  Future<List<dynamic>> getMedicines() async {
    final response = await dio.get('/pharmacy/medicines');
    var data = response.data['data'];
    if (data is List) return data;
    return [];
  }

  Future<List<dynamic>> getRecentSearches() async {
    try {
      final response = await dio.get('/pharmacy/search/recent');
      var data = response.data['data'];
      return data is List ? data : [];
    } catch (e) {
      return [];
    }
  }

  Future<void> notifyMe(String pharmacyId) async {
    await dio.post('/pharmacy/notify', data: {'pharmacyId': pharmacyId});
  }

  // 🆕 إرسال موقع اليوزر للسيرفر عشان يستخدمه في البحث
  Future<void> updateUserLocation(
      {required double lat, required double lng}) async {
    final formData = FormData.fromMap({
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'lat': lat.toString(),
      'lng': lng.toString(),
    });
    await dio.post('/profile/location', data: formData);
  }
}
