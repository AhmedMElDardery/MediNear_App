class AdEntity {
  final String id;
  final String imageUrl;
  final String? title;
  final String? redirectUrl;
  final String? description;
  final String? backgroundColor;
  final String? iconUrl;
  final String? coupon;

  const AdEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.redirectUrl,
    this.description,
    this.backgroundColor,
    this.iconUrl,
    this.coupon,
  });
}
