import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.time,
    required super.icon,
    required super.iconColor,
    super.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: json['time'] ?? '',
      icon: Icons.notifications, 
      iconColor: Colors.blue,
      isRead: json['isRead'] ?? false,
    );
  }
}