import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> fetchNotificationsFromApi() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      NotificationModel(
          id: '1',
          title: 'Medication Reminder',
          body: 'Time to take your Lipitor 20mg.',
          time: '5m ago',
          icon: Icons.medication,
          iconColor: Colors.redAccent),
      NotificationModel(
          id: '2',
          title: 'Order Confirmed',
          body: 'Order #4092 is being prepared.',
          time: '1h ago',
          icon: Icons.check_circle,
          iconColor: Colors.green),
      NotificationModel(
          id: '3',
          title: 'Driver Nearby',
          body: 'Ahmed is 5 minutes away.',
          time: '2h ago',
          icon: Icons.delivery_dining,
          iconColor: Colors.blueAccent),
      NotificationModel(
          id: '4',
          title: 'Flash Sale',
          body: 'Get 50% off Multivitamins!',
          time: '3h ago',
          icon: Icons.flash_on,
          iconColor: Colors.orange,
          isRead: true),
      NotificationModel(
          id: '5',
          title: 'Prescription Renewed',
          body: 'Doctor approved Panadol Extra.',
          time: '5h ago',
          icon: Icons.receipt_long,
          iconColor: Colors.teal),
      NotificationModel(
          id: '6',
          title: 'Payment Successful',
          body: 'VISA ending in 8821 was charged.',
          time: 'Yesterday',
          icon: Icons.credit_card,
          iconColor: Colors.purple,
          isRead: true),
      NotificationModel(
          id: '7',
          title: 'Item Restocked',
          body: 'CeraVe Cleanser is back.',
          time: 'Yesterday',
          icon: Icons.inventory_2,
          iconColor: Colors.indigo,
          isRead: true),
      NotificationModel(
          id: '8',
          title: 'Points Earned',
          body: 'You earned 50 loyalty points.',
          time: 'Yesterday',
          icon: Icons.star,
          iconColor: Colors.amber,
          isRead: true),
    ];
  }
}
