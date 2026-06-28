import '../entities/notification_entity.dart';
import '../../data/models/notification_response_model.dart';

abstract class NotificationsRepository {
  Future<NotificationResponseModel> getNotifications({int page = 1});
  Future<int> getUnreadCount();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  Future<void> deleteNotification(String id);
  Future<void> deleteAllNotifications();
}
