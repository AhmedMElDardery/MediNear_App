import 'package:medinear_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.imageUrl,
    super.location,
    super.latitude,
    super.longitude,
    required super.role,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      imageUrl: json['photo_url'],
      // جلب الموقع أو استخدام null إذا لم يكن موجوداً
      location: json['location'] ?? json['address'] ?? json['city'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      role: json['role'],
      token: token,
    );
  }
}