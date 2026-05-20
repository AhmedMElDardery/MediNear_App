import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';
import 'package:medinear_app/features/packets/domain/repositories/packets_repository.dart';

class MockPacketsRepositoryImpl implements PacketsRepository {
  final List<PacketEntity> _mockPackets = [
    PacketEntity(
      id: "1",
      name: "Family Prescriptions",
      colorHex: "#FF5252",
      itemCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PacketEntity(
      id: "2",
      name: "Chronic Meds",
      colorHex: "#4CAF50",
      itemCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  final Map<String, List<PacketItemEntity>> _mockItems = {
    "1": [
      PacketItemEntity(
        id: "i1",
        packetId: "1",
        type: PacketItemType.note,
        title: "Doctor's Advice",
        content: "Take Panadol every 8 hours after meals.",
        createdAt: DateTime.now(),
      ),
      PacketItemEntity(
        id: "i2",
        packetId: "1",
        type: PacketItemType.prescription,
        title: "Dermatologist Rx",
        imageUrl: "https://medinear-eg.com/storage/categories/zjqiOo15QuTzUnHA8cvO2JQcs4mX3Y1jYp8luwMJ.png",
        createdAt: DateTime.now(),
      ),
    ],
    "2": [],
  };

  @override
  Future<List<PacketEntity>> getPackets() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return _mockPackets;
  }

  @override
  Future<PacketEntity> createPacket(String name, String colorHex) async {
    await Future.delayed(const Duration(seconds: 1));
    final newPacket = PacketEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorHex: colorHex,
      createdAt: DateTime.now(),
      itemCount: 0,
    );
    _mockPackets.insert(0, newPacket);
    _mockItems[newPacket.id] = [];
    return newPacket;
  }

  @override
  Future<void> deletePacket(String packetId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockPackets.removeWhere((p) => p.id == packetId);
    _mockItems.remove(packetId);
  }

  @override
  Future<List<PacketItemEntity>> getPacketItems(String packetId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockItems[packetId] ?? [];
  }

  @override
  Future<PacketItemEntity> addPacketItem(
    String packetId, 
    PacketItemType type, 
    {String? title, String? content, String? imageUrl, String? medicineId, String? imagePath}
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final newItem = PacketItemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      packetId: packetId,
      type: type,
      title: title,
      content: content,
      imageUrl: imageUrl,
      medicineId: medicineId,
      createdAt: DateTime.now(),
    );
    
    if (_mockItems[packetId] != null) {
      _mockItems[packetId]!.insert(0, newItem);
      
      // Update item count
      final index = _mockPackets.indexWhere((p) => p.id == packetId);
      if (index != -1) {
        _mockPackets[index] = _mockPackets[index].copyWith(
          itemCount: _mockPackets[index].itemCount + 1,
        );
      }
    }
    
    return newItem;
  }
}
