import 'package:dio/dio.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import '../models/pharmacy_models.dart';

class PharmacyRemoteDataSource {
  // 🚀 تعريف الـ Dio مباشرة هنا عشان منبوظش الـ Provider Setup بتاعك
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://medinear-eg.com/api'));
  final TokenStorage tokenStorage = TokenStorage();

  // 1. جلب بيانات الصيدلية (الـ Inventory) وحالة الحفظ
  Future<Map<String, dynamic>> getPharmacyDetails(String pharmacyId) async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.get(
        '/pharmacy/$pharmacyId/inventory',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final apiData = response.data['data'] ?? response.data;

      // 🛑 الداتا الوهمية بتاعتك (سايبها كـ Fallback عشان لو السيرفر مرجعش أدوية الشاشة متضربش)
      final dummyMedicines = [
        {
          'id': 1,
          'name': 'valtaren Emulgel',
          'oldPrice': 300.0,
          'price': 250.0,
          'discount': 20,
          'rating': 4.5,
          'inStock': true,
          'notifyAvailable': false,
          'isSaved': false,
          'image': 'assets/images/medicine_2.jpg'
        },
        {
          'id': 2,
          'name': 'Hypooeh',
          'oldPrice': 320.0,
          'price': 220.0,
          'discount': 30,
          'rating': 4.8,
          'inStock': false,
          'notifyAvailable': true,
          'isSaved': false,
          'image': 'assets/images/medicine_6.jpg'
        },
      ];
      final dummyDoctors = [
        {
          'id': 1,
          'name': 'Dr. Amany Mohamed',
          'specialty': 'Cardiologist',
          'rating': 4.8,
          'isSaved': false,
          'image': 'assets/images/dr1.jpg'
        },
      ];
      final dummyServices = [
        {
          'id': 1,
          'name': 'Blood Pressure Check',
          'price': 50.0,
          'duration': '15 min',
          'isSaved': false,
          'image': 'assets/images/blood.jpg'
        },
      ];

      final pharmacyInfo = apiData['pharmacy_info'] ?? {};
      final isSavedRaw =
          pharmacyInfo['is_saved'] ?? apiData['is_saved'] ?? apiData['isSaved'];
      final bool isSaved = isSavedRaw == true ||
          isSavedRaw == 1 ||
          isSavedRaw.toString() == '1' ||
          isSavedRaw.toString().toLowerCase() == 'true';

      List<dynamic> parsedMedicines = [];
      if (apiData['inventory'] != null && apiData['inventory'] is List) {
        for (var category in apiData['inventory']) {
          if (category['medicines'] != null && category['medicines'] is List) {
            parsedMedicines.addAll(category['medicines']);
          }
        }
      } else if (apiData['medicines'] != null && apiData['medicines'] is List) {
        parsedMedicines = apiData['medicines'];
      }

      return {
        // 🚀 بناخد حالة الحفظ من السيرفر
        'is_saved': isSaved,
        // لو السيرفر رجع أدوية بناخدها، لو لأ بناخد الوهمية
        'medicines': parsedMedicines.isNotEmpty
            ? parsedMedicines
                .map((e) => PharmacyMedicineModel.fromJson(e))
                .toList()
            : dummyMedicines
                .map((e) => PharmacyMedicineModel.fromJson(e))
                .toList(),
        'doctors': apiData['doctors'] != null
            ? (apiData['doctors'] as List)
                .map((e) => PharmacyDoctorModel.fromJson(e))
                .toList()
            : dummyDoctors.map((e) => PharmacyDoctorModel.fromJson(e)).toList(),
        'services': apiData['services'] != null
            ? (apiData['services'] as List)
                .map((e) => PharmacyServiceModel.fromJson(e))
                .toList()
            : dummyServices
                .map((e) => PharmacyServiceModel.fromJson(e))
                .toList(),
      };
    } catch (e) {
      throw Exception("Failed to fetch pharmacy details: $e");
    }
  }

  // 2. 🚀 دالة حفظ الصيدلية الجديدة
  Future<bool> toggleSavePharmacy(String pharmacyId) async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.post(
        '/pharmacy/save/pharmacy',
        data: {'pharmacy_id': pharmacyId}, // الباك إند بيستقبل الـ ID هنا
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // بنقرأ الـ success من الـ API، ولو مش موجودة بنعتمد على إن الـ Status Code 200
        final isSuccess =
            response.data['success'] ?? response.data['status'] ?? true;
        return isSuccess == true;
      }
      return false;
    } catch (e) {
      return false; // لو حصل مشكلة يرجع False
    }
  }
}
