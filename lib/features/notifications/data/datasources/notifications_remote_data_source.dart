import 'package:dio/dio.dart';
import '../../../../core/network/dio_clilent.dart'; // Typo in filename in original code
import '../models/notification_response_model.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final DioClient dioClient;

  NotificationsRemoteDataSource({required this.dioClient});

  Future<NotificationResponseModel> fetchNotificationsFromApi({int page = 1}) async {
    try {
      final response = await dioClient.dio.get('/notifications', queryParameters: {
        'page': page,
      });

      if (response.data['status'] == 'success') {
        return NotificationResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.dio.get('/notifications/unread-count');
      if (response.data['status'] == 'success') {
        return response.data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Assuming POST based on typical API designs, though we should confirm with user.
      await dioClient.dio.post('/notifications/read-all');
    } catch (e) {
      throw Exception('Failed to mark all as read');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      // Assuming POST
      await dioClient.dio.post('/notifications/$id/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await dioClient.dio.delete('/notifications/$id');
    } catch (e) {
      throw Exception('Failed to delete notification');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await dioClient.dio.delete('/notifications');
    } catch (e) {
      throw Exception('Failed to delete all notifications');
    }
  }
}
