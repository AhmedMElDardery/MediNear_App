import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();

  }
  static bool isFirstTime() => _prefs.getBool("first_time") ?? true;

  static Future setFirstTimeFalse() async => _prefs.setBool("first_time", false);
}