import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.notificationType,
    super.actionUrl,
    required super.createdAt,
    super.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final dataObj = json['data'] ?? {};
    
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: dataObj['title'] ?? '',
      message: dataObj['message'] ?? '',
      notificationType: dataObj['type'] ?? 'info',
      actionUrl: dataObj['action_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isRead: json['read_at'] != null,
    );
  }
}
