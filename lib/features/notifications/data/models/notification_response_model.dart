import 'notification_model.dart';

class NotificationResponseModel {
  final int unreadCount;
  final int currentPage;
  final int lastPage;
  final List<NotificationModel> data;

  NotificationResponseModel({
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
    required this.data,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    final notificationsObj = json['notifications'] ?? {};
    final dataList = notificationsObj['data'] as List<dynamic>? ?? [];

    return NotificationResponseModel(
      unreadCount: json['unread_count'] ?? 0,
      currentPage: notificationsObj['current_page'] ?? 1,
      lastPage: notificationsObj['last_page'] ?? 1,
      data: dataList.map((e) => NotificationModel.fromJson(e)).toList(),
    );
  }
}
