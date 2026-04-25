import 'package:dio/dio.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import '../models/saved_item_models.dart';

class SavedItemsRemoteDataSource {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://medinear-eg.com/api'));
  final TokenStorage tokenStorage = TokenStorage();

  // 1. جلب المحفوظات (GET)
  Future<Map<String, List<dynamic>>> getSavedItems() async {
    try {
      final token = await tokenStorage.getToken();

      final response = await dio.get(
        '/pharmacy/pharmacy/saved',
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json" // 🚀 عشان نضمن إنه يرجع JSON دايماً
        }),
      );

      // 🚀 1. فك شفرة الصفحات (Pagination)
      // الداتا جاية جوه response.data['data']['data']
      final rawData = response.data['data']?['data'] as List? ?? [];

      // 🚀 2. الترجمة (Mapping): بنحول أسماء السيرفر لأسماء الموديل بتاعك
      List<SavedPharmacyModel> realPharmacies = rawData.map((item) {
        // بننضف العنوان من المسافات الزيادة والسطور الجديدة
        String fullAddress = '${item['city'] ?? ''} - ${item['address'] ?? ''}'
            .replaceAll('\n', ' ');

        return SavedPharmacyModel.fromJson({
          'id': item['pharmacy_id']?.toString() ??
              item['pharmacy']?['id']?.toString() ??
              item['id'].toString(),
          'name': item['pharmacy_name'] ??
              'صيدلية بدون اسم', // بناخد الاسم من pharmacy_name
          'location': fullAddress, // بندمج المدينة مع العنوان
          'products':
              item['distance_text'] ?? 'متوفرة', // ممكن نعرض المسافة مؤقتاً هنا
          'image':
              item['image'] ?? 'assets/images/dr1.jpg', // صورة افتراضية لو مفيش
          'isSaved': true,
        });
      }).toList();

      // أدوية وهمية مؤقتة لحد ما تظبطوا الـ API بتاعها
      final dummyMedications = [
        {
          'id': '101',
          'name': 'Voltaren Emulgel',
          'price': '90 EGP',
          'available': false,
          'image': 'assets/images/medicine_2.png',
          'isSaved': true
        },
        {
          'id': '102',
          'name': 'Hypooeh',
          'price': '110 EGP',
          'available': false,
          'image': 'assets/images/medicine_1.png',
          'isSaved': true
        },
      ];

      return {
        'pharmacies': realPharmacies,
        'medications': dummyMedications
            .map((e) => SavedMedicationModel.fromJson(e))
            .toList(),
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
        final isSuccess =
            response.data['success'] ?? response.data['status'] ?? true;
        return isSuccess == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
