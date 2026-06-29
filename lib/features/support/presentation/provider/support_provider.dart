import 'package:flutter/material.dart';
import 'package:medinear_app/core/utils/launcher_helper.dart';
import 'package:medinear_app/features/support/data/models/support_item_model.dart';

class SupportProvider extends ChangeNotifier {
  List<SupportItemModel> items = [];

  void init(BuildContext context) {
    items = [
      SupportItemModel(
        title: "Call Us",
        subtitle: "+20120000555555",
        buttonText: "Call now",
        icon: Icons.phone,
        onTap: () {
          LauncherHelper.makePhoneCall("+20120000555555");
        },
      ),
      SupportItemModel(
        title: "WhatsApp",
        subtitle: "+20120000555555",
        buttonText: "Chat now",
        icon: Icons.chat,
        onTap: () {
          LauncherHelper.openWhatsApp("+20120000555555");
        },
      ),
      SupportItemModel(
        title: "Email Us",
        subtitle: "MediNearapp@Yahoo.com",
        buttonText: "Send Email",
        icon: Icons.email,
        onTap: () {
          LauncherHelper.sendEmail("MediNearapp@Yahoo.com");
        },
      ),
    ];
    notifyListeners();
  }
}
