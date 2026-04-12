class PharmacyEntity {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double distance;
  final bool hasMedicine;
  final String availabilityStatus; // ضفناها عشان لو حابين نعرضها

  PharmacyEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.hasMedicine,
    required this.availabilityStatus,
  });
}