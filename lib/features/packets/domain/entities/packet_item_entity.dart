enum PacketItemType { prescription, note, medicine }

class PacketItemEntity {
  final String id;
  final String packetId;
  final PacketItemType type;
  final String? title;
  final String? content; // For notes
  final String? imageUrl; // For prescriptions
  final String? medicineId; // For linked medicines
  final DateTime createdAt;

  PacketItemEntity({
    required this.id,
    required this.packetId,
    required this.type,
    this.title,
    this.content,
    this.imageUrl,
    this.medicineId,
    required this.createdAt,
  });
}
