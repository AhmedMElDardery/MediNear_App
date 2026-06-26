import '../../data/models/notification_response_model.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<NotificationResponseModel> execute({int page = 1}) async {
    return await repository.getNotifications(page: page);
  }
}
