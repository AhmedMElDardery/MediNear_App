class PharmacyEntity {
  final String id;
  final String name;
  final String image;
  final String address;
  final String? phone;
  final String? workingHours;
  final String? distance;

  PharmacyEntity(
      {required this.id,
      required this.name,
      required this.image,
      required this.address,
      this.distance,
      this.phone,
      this.workingHours});
}
