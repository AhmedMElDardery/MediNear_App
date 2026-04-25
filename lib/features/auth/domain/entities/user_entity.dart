class UserEntity {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? location; // تمت إضافة العنوان / الموقع
  final double? latitude; // تمت إضافة خط العرض
  final double? longitude; // تمت إضافة خط الطول
  final String role;
  final String token;

  UserEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.imageUrl,
    this.location,
    this.latitude,
    this.longitude,
    required this.role,
    required this.token,
  });
}
