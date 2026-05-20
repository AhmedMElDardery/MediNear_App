import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';

class PacketItemModel extends PacketItemEntity {
  PacketItemModel({
    required super.id,
    required super.packetId,
    required super.type,
    super.title,
    super.content,
    super.imageUrl,
    super.medicineId,
    required super.createdAt,
  });

  factory PacketItemModel.fromJson(Map<String, dynamic> json) {
    PacketItemType determineType(String? typeStr) {
      if (typeStr == 'prescription' || typeStr == 'image') return PacketItemType.prescription;
      if (typeStr == 'medicine') return PacketItemType.medicine;
      return PacketItemType.note;
    }

    return PacketItemModel(
      id: json['id'].toString(),
      packetId: json['packet_id']?.toString() ?? "",
      type: determineType(json['type']?.toString()),
      title: json['title']?.toString(), // Backend might not return title, we handle it below
      content: json['note']?.toString() ?? json['content']?.toString(),
      imageUrl: json['image']?.toString() ?? json['image_url']?.toString(),
      medicineId: json['medicine_id']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
