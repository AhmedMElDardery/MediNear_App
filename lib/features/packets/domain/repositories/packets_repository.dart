import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';

abstract class PacketsRepository {
  Future<List<PacketEntity>> getPackets();
  Future<PacketEntity> createPacket(String name, String colorHex);
  Future<void> deletePacket(String packetId);
  Future<List<PacketItemEntity>> getPacketItems(String packetId);
  Future<PacketItemEntity> addPacketItem(
    String packetId, 
    PacketItemType type, 
    {String? title, String? content, String? imageUrl, String? medicineId, String? imagePath}
  );
  Future<void> deletePacketItem(String packetId, String itemId);
}
