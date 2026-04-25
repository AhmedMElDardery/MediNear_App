import 'package:dio/dio.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import '../models/cart_item_model.dart';
import '../models/cart_pharmacy_model.dart';
import '../models/cart_pharmacy_details_model.dart';

class CartRemoteDataSource {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://medinear-eg.com/api'));
  final TokenStorage tokenStorage = TokenStorage();

  Future<List<CartPharmacyModel>> getCartPharmacies() async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.get(
        '/pharmacy/save/cart/pharmacies',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((e) => CartPharmacyModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception("Failed to load cart pharmacies: $e");
    }
  }

  Future<CartPharmacyDetailsModel?> getPharmacyCartItems(int pharmacyId) async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.post(
        '/pharmacy/save/cart/items',
        data: FormData.fromMap({
          'pharmacy_id': pharmacyId,
        }),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return CartPharmacyDetailsModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to load pharmacy cart items: $e");
    }
  }

  Future<bool> toggleCartItem({
    required int medicineId,
    required int pharmacyId,
    int? quantity,
  }) async {
    try {
      final token = await tokenStorage.getToken();
      
      final Map<String, dynamic> dataMap = {
        'medicine_id': medicineId,
        'pharmacy_id': pharmacyId,
      };
      if (quantity != null) {
        dataMap['quantity'] = quantity;
      }

      final response = await dio.post(
        '/pharmacy/save/cart',
        data: FormData.fromMap(dataMap),
        options: Options(headers: {"Authorization": "Bearer $token"}),
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
}
