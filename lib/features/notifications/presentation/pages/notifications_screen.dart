import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';

import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../manager/notifications_provider.dart';
import '../widgets/notification_item_widget.dart';

// ✅ AutoDispose provider defined at file scope for Riverpod
final notificationsProvider =
    ChangeNotifierProvider.autoDispose<NotificationsProvider>((ref) {
  return NotificationsProvider(
    getNotificationsUseCase: GetNotificationsUseCase(
      NotificationsRepositoryImpl(
        remoteDataSource: NotificationsRemoteDataSource(),
      ),
    ),
  );
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = ref.watch(notificationsProvider);
    final notifications = provider.displayedNotifications;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
        title: Text(
          'Notifications',
          style: TextStyle(
              color: theme.appBarTheme.foregroundColor,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : Column(
              children: [
                Container(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterButton(
                          context, ref, 'All', theme.primaryColor, isDark),
                      const SizedBox(width: 12),
                      _buildFilterButton(
                          context, ref, 'Unread', theme.primaryColor, isDark),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh,
                    color: theme.primaryColor,
                    child: notifications.isEmpty
                        ? _buildEmptyState(theme.textTheme.bodyMedium?.color)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: notifications.length +
                                (provider.hasMoreItems ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == notifications.length) {
                                return _buildLoadMoreButton(
                                    context, ref, theme.primaryColor);
                              }

                              final item = notifications[index];

                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.white, size: 28),
                                ),
                                onDismissed: (_) {
                                  final deletedItem =
                                      provider.deleteItem(item.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text('Notification deleted'),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        textColor: Colors.yellowAccent,
                                        onPressed: () {
                                          if (deletedItem != null) {
                                            provider.restoreItem(deletedItem);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: NotificationItemWidget(
                                  item: item,
                                  onTap: () => provider.markAsRead(item.id),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                _buildBottomActionArea(context, ref, theme.primaryColor,
                    isDark ? Colors.grey[900]! : Colors.white),
              ],
            ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref, String text,
      Color activeColor, bool isDark) {
    final provider = ref.watch(notificationsProvider);
    bool isSelected = provider.currentFilter == text;
    return GestureDetector(
      onTap: () => provider.setFilter(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: activeColor)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(
      BuildContext context, WidgetRef ref, Color color) {
    final provider = ref.read(notificationsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: TextButton.icon(
          onPressed: provider.loadMore,
          icon: Icon(Icons.expand_more, color: color),
          label: Text('Load More',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
              backgroundColor: color.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color? textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 40, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No notifications',
              style: TextStyle(
                  color: textColor ?? Colors.grey[800],
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea(
      BuildContext context, WidgetRef ref, Color color, Color backgroundColor) {
    final provider = ref.read(notificationsProvider);
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 25),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, -5))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            provider.markAllAsRead();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All marked as read')));
          },
          icon: const Icon(Icons.done_all_rounded, color: Colors.white),
          label: const Text('Mark All as Read',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
        ),
      ),
    );
  }
}
