import 'package:flutter/material.dart';

class NotificationEntity {
  final String id;
  final String type;
  final String title;
  final String message;
  final String notificationType;
  final String? actionUrl;
  final DateTime createdAt;
  bool isRead;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.notificationType,
    this.actionUrl,
    required this.createdAt,
    this.isRead = false,
  });
}
