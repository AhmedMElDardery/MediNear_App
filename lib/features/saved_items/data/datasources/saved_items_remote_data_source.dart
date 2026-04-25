import 'package:dio/dio.dart';
import '../../../../core/services/token_storage.dart';
import '../models/saved_item_models.dart';

class SavedItemsRemoteDataSource {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://medinear-eg.com/api'));
  final TokenStorage tokenStorage = TokenStorage();

  // 1. جلب المحفوظات (GET)
  Future<Map<String, List<dynamic>>> getSavedItems() async {
    try {
      final token = await tokenStorage.getToken();
      
      // 🚀 إرسال طلبين في نفس الوقت عشان السرعة
      final responses = await Future.wait([
        dio.get(
          '/pharmacy/pharmacy/saved',
          options: Options(headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json"
          }),
        ),
        dio.get(
          '/pharmacy/medicine/saved',
          options: Options(headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json"
          }),
        )
      ]);

      final pharmaciesResponse = responses[0];
      final medicinesResponse = responses[1];

      // 🚀 1. فك شفرة الصفحات للصيدليات
      final rawPharmaciesData = pharmaciesResponse.data['data']?['data'] as List? ?? [];

      // 🚀 2. الترجمة للصيدليات
      List<SavedPharmacyModel> realPharmacies = rawPharmaciesData.map((item) {
        String fullAddress = '${item['city'] ?? ''} - ${item['address'] ?? ''}'.replaceAll('\n', ' ');
        String rawImage = item['image'] ?? 'assets/images/dr1.jpg';

        return SavedPharmacyModel.fromJson({
          'id': item['pharmacy_id']?.toString() ?? item['pharmacy']?['id']?.toString() ?? item['id'].toString(), 
          'name': item['pharmacy_name'] ?? 'صيدلية بدون اسم', 
          'location': fullAddress, 
          'products': item['distance_text'] ?? 'متوفرة', 
          'image': rawImage.startsWith('http') || rawImage.startsWith('assets') 
              ? rawImage 
              : 'https://medinear-eg.com/storage/$rawImage', 
          'isSaved': true,
        });
      }).toList();

      // 🚀 3. فك شفرة الأدوية
      final rawMedicinesData = medicinesResponse.data['data']?['data'] as List? ?? [];
      
      List<SavedMedicationModel> realMedicines = rawMedicinesData.map((item) {
        final medicineObj = item['medicine'] ?? item['pharmacy_medicine'] ?? {};
        final pivotObj = item['pivot'] ?? {};
        
        // الأيدي بتاع الصيدلية من السيرفر بيكون جوه item['pharmacy']['id']
        final pId = item['pharmacy']?['id']?.toString() ?? pivotObj['pharmacy_id']?.toString() ?? item['pharmacy_id']?.toString() ?? medicineObj['pharmacy_id']?.toString() ?? '0';

        // الأيدي بتاع الدواء 
        final mId = item['medicine']?['id']?.toString() ?? pivotObj['medicine_id']?.toString() ?? item['medicine_id']?.toString() ?? medicineObj['id']?.toString() ?? item['id']?.toString() ?? '0';
        
        // الاسم
        final mName = item['medicine']?['name'] ?? item['name'] ?? item['medicine_name'] ?? medicineObj['name'] ?? 'دواء بدون اسم';
        
        // السعر (للأسف الـ API ده مش بيرجع السعر فهيفضل 0 في حالة المحفوظات، وممكن نكتب كلمة السعر غير محدد)
        final mPrice = item['price'] ?? medicineObj['price'] ?? pivotObj['price'] ?? item['official_price'] ?? item['medicine']?['official_price'] ?? 0;
        
        // الصورة
        String mImage = item['medicine']?['image'] ?? item['image'] ?? medicineObj['image'] ?? 'assets/images/medicine_2.jpg';
        if (!mImage.startsWith('http') && !mImage.startsWith('assets')) {
          mImage = 'https://medinear-eg.com/storage/$mImage';
        }
        
        // التوفر
        final mAvailable = pivotObj['status'] == 'available' || item['in_stock'] == true || item['status'] == true || item['medicine']?['status'] == true;

        // اسم الصيدلية
        final pName = item['pharmacy']?['pharmacy_name'] ?? item['pharmacy_name'] ?? 'صيدلية غير معروفة';
        
        // صورة الصيدلية
        String? pImage = item['pharmacy']?['image'] ?? item['pharmacy_image'];
        if (pImage != null && !pImage.startsWith('http') && !pImage.startsWith('assets')) {
          pImage = 'https://medinear-eg.com/storage/$pImage';
        }

        return SavedMedicationModel.fromJson({
          'id': mId,
          'name': mName,
          'price': mPrice == 0 || mPrice == '0' ? 'السعر غير محدد' : '${mPrice} EGP',
          'available': mAvailable,
          'image': mImage,
          'isSaved': true,
          'pharmacy_id': pId,
          'pharmacy_name': pName,
          'pharmacy_image': pImage,
        });
      }).toList();

      return {
        'pharmacies': realPharmacies, 
        'medications': realMedicines,
      };
    } catch (e) {
      throw Exception("Failed to fetch saved items: $e");
    }
  }

  // 2. إلغاء/إعادة الحفظ (POST)
  Future<bool> toggleSavePharmacy(String pharmacyId) async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.post(
        '/pharmacy/save/pharmacy',
        data: {'pharmacy_id': pharmacyId},
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final isSuccess = response.data['success'] ?? response.data['status'] ?? true;
        return isSuccess == true;
      }
      return false;
    } catch (e) {
      return false; 
    }
  }

  // 3. إلغاء/إعادة حفظ الدواء (POST)
  Future<dynamic> toggleSaveMedicine(String medicineId, String pharmacyId) async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.post(
        '/pharmacy/save/medicine',
        data: {
          'medicine_id': int.tryParse(medicineId) ?? medicineId, 
          'pharmacy_id': int.tryParse(pharmacyId) ?? pharmacyId
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final isSuccess = response.data['success'] ?? response.data['status'] ?? true;
        if (isSuccess == true) return true;
        return response.data['message'] ?? 'Unknown API logic error';
      }
      return 'Error: HTTP ${response.statusCode}';
    } on DioException catch (e) {
      if (e.response != null) {
        return 'API Error: ${e.response?.statusCode} - ${e.response?.data}';
      }
      return 'Network Error: ${e.message}';
    } catch (e) {
      return 'Exception: $e'; 
    }
  }
}