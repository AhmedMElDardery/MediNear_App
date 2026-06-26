import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_response_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationResponseModel> getNotifications({int page = 1}) async {
    return await remoteDataSource.fetchNotificationsFromApi(page: page);
  }

  @override
  Future<int> getUnreadCount() async {
    return await remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAllAsRead() async {
    return await remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> markAsRead(String id) async {
    return await remoteDataSource.markAsRead(id);
  }
}
