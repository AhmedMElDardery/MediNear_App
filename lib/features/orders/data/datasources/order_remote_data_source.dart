import 'package:dio/dio.dart';
import '../../../../core/network/dio_clilent.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSource({required this.dioClient});

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await dioClient.dio.get('/pharmacy/orders');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> dataList = [];

        if (responseData is Map<String, dynamic>) {
          // If the response is wrapped in {"data": {"data": [...]}} or {"data": [...]}
          if (responseData.containsKey('data')) {
            final innerData = responseData['data'];
            if (innerData is Map<String, dynamic> && innerData.containsKey('data') && innerData['data'] is List) {
              dataList = innerData['data'] as List<dynamic>;
            } else if (innerData is List) {
              dataList = innerData as List<dynamic>;
            }
          }
        } else if (responseData is List) {
          dataList = responseData;
        }

        return dataList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

