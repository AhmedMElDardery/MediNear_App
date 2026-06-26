import 'package:medinear_app/features/packets/data/datasources/packets_remote_data_source.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';
import 'package:medinear_app/features/packets/domain/repositories/packets_repository.dart';

class PacketsRepositoryImpl implements PacketsRepository {
  final PacketsRemoteDataSource remoteDataSource;

  PacketsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PacketEntity>> getPackets() async {
    final models = await remoteDataSource.getPackets();
    // Use List<PacketEntity>.from() to avoid runtime type covariance issues
    return List<PacketEntity>.from(models);
  }

  @override
  Future<PacketEntity> createPacket(String name, String colorHex) async {
    final model = await remoteDataSource.createPacket(name, colorHex);
    return PacketEntity(
      id: model.id,
      name: model.name,
      colorHex: model.colorHex,
      itemCount: model.itemCount,
      createdAt: model.createdAt,
    );
  }

  @override
  Future<void> deletePacket(String packetId) async {
    await remoteDataSource.deletePacket(packetId);
  }

  @override
  Future<List<PacketItemEntity>> getPacketItems(String packetId) async {
    final models = await remoteDataSource.getPacketItems(packetId);
    // Use List<PacketItemEntity>.from() to avoid runtime type covariance issues
    return List<PacketItemEntity>.from(models);
  }

  @override
  Future<PacketItemEntity> addPacketItem(
    String packetId, 
    PacketItemType type, 
    {String? title, String? content, String? imageUrl, String? medicineId, String? imagePath}
  ) async {
    String typeStr;
    switch (type) {
      case PacketItemType.note:
        typeStr = 'note';
        break;
      case PacketItemType.prescription:
        typeStr = 'prescription';
        break;
      case PacketItemType.medicine:
        typeStr = 'medicine';
        break;
    }

    final model = await remoteDataSource.addPacketItem(
      packetId,
      typeStr,
      title: title,
      content: content,
      imageUrl: imageUrl,
      medicineId: medicineId,
      imagePath: imagePath,
    );

    // Return a plain PacketItemEntity to avoid runtime type issues
    return PacketItemEntity(
      id: model.id,
      packetId: model.packetId,
      type: model.type,
      title: model.title,
      content: model.content,
      imageUrl: model.imageUrl,
      medicineId: model.medicineId,
      createdAt: model.createdAt,
    );
  }

  @override
  Future<void> deletePacketItem(String packetId, String itemId) async {
    await remoteDataSource.deletePacketItem(packetId, itemId);
  }
}
