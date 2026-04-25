class AdModel {
  final String id;
  final String imageUrl;

  AdModel({
    required this.id,
    required this.imageUrl,
  });

  // دالة عشان تحول الداتا اللي جاية من السيرفر (أو الوهمية) لموديل
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
