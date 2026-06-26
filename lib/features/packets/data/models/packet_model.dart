import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';

class PacketModel extends PacketEntity {
  PacketModel({
    required super.id,
    required super.name,
    required super.colorHex,
    super.itemCount,
    required super.createdAt,
  });

  factory PacketModel.fromJson(Map<String, dynamic> json) {
    // Determine color from description if it's a hex code, otherwise use default
    String desc = json['description']?.toString() ?? "";
    String color = desc.startsWith('#') ? desc : "#2196F3";

    return PacketModel(
      id: json['id'].toString(),
      name: json['title']?.toString() ?? "Unnamed Packet",
      colorHex: color,
      itemCount: 0, // Since API doesn't return count, default to 0 for now
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'description': colorHex,
      'itemCount': itemCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
