import 'package:flutter/material.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}
