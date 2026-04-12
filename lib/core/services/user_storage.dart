import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medinear_app/features/auth/data/models/user_model.dart';
import 'package:medinear_app/features/auth/domain/entities/user_entity.dart';

class UserStorage {
  static const _userKey = 'cached_user';

  Future<void> saveUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'photo_url': user.imageUrl,
      'location': user.location,
      'latitude': user.latitude,
      'longitude': user.longitude,
      'role': user.role,
      'token': user.token,
    };
    await prefs.setString(_userKey, jsonEncode(data));
  }

  Future<UserEntity?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      return UserModel.fromJson(data, data['token'] ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
