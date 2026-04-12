import 'dart:io';

class UserModel {
  String name;
  final String email;
  String phone;
  File? profileImage;
  // 🚀 ضفنا المتغيرين دول عشان نستقبل الصور من السيرفر
  String? photoUrl;
  String? avatar;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.photoUrl,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name']?.toString() ?? 'No Name',
      email: json['email']?.toString() ?? 'No Email',
      phone: json['phone']?.toString() ?? 'No Phone',
      // 🚀 خلينا الموديل يقرا روابط الصور من الـ JSON
      photoUrl: json['photo_url']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}