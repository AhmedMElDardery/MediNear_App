import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

class NotificationsProvider extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;

  List<NotificationEntity> _notifications = [];
  String _currentFilter = 'All'; 
  bool _isLoading = false;
  int _itemsToShow = 6; 

  NotificationsProvider({required this.getNotificationsUseCase}) {
    fetchData(); 
  }

  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;

  List<NotificationEntity> get displayedNotifications {
    List<NotificationEntity> filtered;
    if (_currentFilter == 'Unread') {
      filtered = _notifications.where((n) => !n.isRead).toList();
    } else {
      filtered = _notifications;
    }
    return filtered.take(_itemsToShow).toList();
  }

  bool get hasMoreItems {
    int totalFiltered = _currentFilter == 'Unread' 
        ? _notifications.where((n) => !n.isRead).length 
        : _notifications.length;
    return _itemsToShow < totalFiltered;
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await getNotificationsUseCase.execute();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    _itemsToShow = 6;
    notifyListeners();
  }

  void loadMore() {
    _itemsToShow += 5;
    notifyListeners();
  }

  Future<void> refresh() async {
    _itemsToShow = 6;
    await fetchData();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  NotificationEntity? deleteItem(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final removedItem = _notifications[index];
      _notifications.removeAt(index);
      notifyListeners();
      return removedItem;
    }
    return null;
  }

  void restoreItem(NotificationEntity item) {
    _notifications.add(item);
    _notifications.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id))); 
    notifyListeners();
  }
}