import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/services/pusher_service.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import 'package:medinear_app/core/services/user_storage.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/models/notification_model.dart';

class NotificationsProvider extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;
  final NotificationsRepository repository;
  final TokenStorage tokenStorage;
  final UserStorage userStorage;

  List<NotificationEntity> _notifications = [];
  String _currentFilter = 'All';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  
  int _currentPage = 1;
  int _lastPage = 1;
  int _unreadCount = 0;

<<<<<<< HEAD
  NotificationsProvider({
    required this.getNotificationsUseCase,
    required this.repository,
    required this.tokenStorage,
    required this.userStorage,
  }) {
=======
  bool _isDisposed = false;

  NotificationsProvider({required this.getNotificationsUseCase}) {
>>>>>>> 417e6145c0e893ca10d1e5f2cd360ba803defe5c
    fetchData();
    _initPusher();
  }

  Future<void> _initPusher() async {
    final token = await tokenStorage.getToken();
    final user = await userStorage.loadUser();
    
    if (token == null || user == null) {
      return;
    }

    final channelName = 'private-App.Models.User.${user.id}';
    final eventName = 'Illuminate\\\\Notifications\\\\Events\\\\BroadcastNotificationCreated';

    await PusherService().initPusher(
      appKey: '0f70acb0d542c5b87ebf',
      cluster: 'eu',
      channelName: channelName,
      eventName: eventName,
      token: token,
      onSubscriptionSucceeded: (channelName, data) {
        debugPrint('Pusher Subscribed to $channelName');
      },
      onSubscriptionError: (message, error) {
        debugPrint('Pusher Subscription Error: $message - $error');
      },
      onConnectionStateChange: (currentState, previousState) {
        debugPrint('Pusher Connection State: $currentState');
      },
      onErrorCallback: (message, code, e) {
        debugPrint('Pusher Error: $message - $code - $e');
      },
      onEvent: (event) {
        if (event.eventName.startsWith('pusher')) return;

        try {
          dynamic payload = event.data;
          if (payload is String) {
            payload = jsonDecode(payload);
          }
          if (payload is String) {
            payload = jsonDecode(payload);
          }
          
          final newNotification = NotificationModel.fromJson({
            'id': payload['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'type': payload['type'] ?? '',
            'data': {
              'title': payload['title'] ?? payload['data']?['title'] ?? 'New Notification',
              'message': payload['message'] ?? payload['data']?['message'] ?? '',
              'type': payload['type'] ?? payload['data']?['type'] ?? 'info',
              'action_url': payload['action_url'] ?? payload['data']?['action_url'],
            },
            'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
            'read_at': null,
          });
          
          addRealtimeNotification(newNotification);
        } catch (e, stack) {
          debugPrint('Pusher Parse Error: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get currentFilter => _currentFilter;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  List<NotificationEntity> get displayedNotifications {
    if (_currentFilter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  bool get hasMoreItems => _currentPage < _lastPage;

  Future<void> fetchData() async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();
    try {
      final response = await getNotificationsUseCase.execute(page: _currentPage);
      _notifications = response.data;
      _lastPage = response.lastPage;
      _unreadCount = response.unreadCount;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMoreItems) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      _currentPage++;
      final response = await getNotificationsUseCase.execute(page: _currentPage);
      _notifications.addAll(response.data);
      _lastPage = response.lastPage;
    } catch (e) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchData();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();

      try {
        await repository.markAsRead(id);
      } catch (e) {
        _notifications[index].isRead = false;
        _unreadCount++;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    bool hasUnreadLocal = _notifications.any((n) => !n.isRead);
    if (!hasUnreadLocal && _unreadCount == 0) return;

    for (var n in _notifications) {
      n.isRead = true;
    }
    _unreadCount = 0;
    notifyListeners();

    try {
      await repository.markAllAsRead();
    } catch (e) {
      await fetchData();
    }
  }

  NotificationEntity? deleteItem(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final removedItem = _notifications[index];
      _notifications.removeAt(index);
      if (!removedItem.isRead && _unreadCount > 0) _unreadCount--;
      notifyListeners();
      return removedItem;
    }
    return null;
  }

  void restoreItem(NotificationEntity item) {
    _notifications.add(item);
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!item.isRead) _unreadCount++;
    notifyListeners();
  }

  void addRealtimeNotification(NotificationEntity notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
  
  @override
  void dispose() {
    PusherService().disconnect();
    super.dispose();
  }
}

