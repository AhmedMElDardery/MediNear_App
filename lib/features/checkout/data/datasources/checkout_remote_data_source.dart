import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:medinear_app/core/network/dio_clilent.dart';
import '../models/checkout_summary_model.dart';

// هذا الملف ضروري عشان CheckoutProvider يشتغل
class CheckoutRemoteDataSource {
  final DioClient _dioClient = DioClient();

  Future<CheckoutSummaryModel?> getCheckoutSummary() async {
    try {
      final response = await _dioClient.dio.get('/pharmacy/cart/checkout');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return CheckoutSummaryModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching checkout summary: $e");
    }
    return null;
  }

  Future<CheckoutSummaryModel?> applyCoupon(String couponCode) async {
    try {
      final response = await _dioClient.dio.post(
        '/pharmacy/cart/apply-coupon',
        data: {'coupon_code': couponCode},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return CheckoutSummaryModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error applying coupon: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dioClient.dio.post(
        '/pharmacy/cart/place-order',
        data: orderData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'success': true,
          'payment_url': data['payment_url'],
        };
      }
    } catch (e) {
      debugPrint("Error placing order: $e");
      if (e is DioException && e.response != null) {
        // Return the exact message from the backend so we can debug it
        return {
          'success': false,
          'message': e.response?.data['message'] ?? e.response?.data.toString(),
        };
      }
    }
    return {'success': false, 'message': 'Unknown error occurred'};
  }
}
