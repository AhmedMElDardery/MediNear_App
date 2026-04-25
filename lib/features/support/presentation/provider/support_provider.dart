import 'package:flutter/material.dart';
import 'package:medinear_app/core/utils/launcher_helper.dart';
import 'package:medinear_app/features/support/data/models/support_item_model.dart';

class SupportProvider extends ChangeNotifier {
  List<SupportItemModel> items = [];

  void init(BuildContext context) {
    items = [
      SupportItemModel(
        title: "Call Us",
        subtitle: "+201234567890",
        buttonText: "Call now",
        icon: Icons.phone,
        onTap: () {
          LauncherHelper.makePhoneCall("+201143173960");
        },
      ),
      SupportItemModel(
        title: "WhatsApp",
        subtitle: "+201143173960",
        buttonText: "Chat now",
        icon: Icons.chat,
        onTap: () {
          LauncherHelper.openWhatsApp("+201143173960");
        },
      ),
      SupportItemModel(
        title: "Email Us",
        subtitle: "nharmdan15@gmail.com",
        buttonText: "Send Email",
        icon: Icons.email,
        onTap: () {
          LauncherHelper.sendEmail("nharmdan15@gmail.com");
        },
      ),
    ];
    notifyListeners();
  }
}
