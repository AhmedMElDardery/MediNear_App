import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  static Future<void> makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Can't launch call";
    }
  }

  static Future<void> openWhatsApp(String phone) async {
    final Uri url = Uri.parse("https://wa.me/$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "WhatsApp not installed";
    }
  }

  static Future<void> sendEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support&body=Hello',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Can't send email";
    }
  }
}