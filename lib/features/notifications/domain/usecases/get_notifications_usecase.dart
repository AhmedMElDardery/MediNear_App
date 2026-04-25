import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> execute() async {
    return await repository.getNotifications();
  }
}
