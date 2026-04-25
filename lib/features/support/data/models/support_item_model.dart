import 'package:flutter/material.dart';

class SupportItemModel {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final Function onTap;

  SupportItemModel({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.onTap,
  });
}
