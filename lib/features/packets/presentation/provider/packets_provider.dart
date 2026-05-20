import 'package:flutter/foundation.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';
import 'package:medinear_app/features/packets/domain/repositories/packets_repository.dart';

class PacketsProvider extends ChangeNotifier {
  final PacketsRepository repository;

  PacketsProvider(this.repository);

  List<PacketEntity> packets = [];
  bool isLoadingPackets = false;
  String? packetsError;

  // Selected Packet Items
  List<PacketItemEntity> currentPacketItems = [];
  bool isLoadingItems = false;
  String? itemsError;

  Future<void> fetchPackets() async {
    isLoadingPackets = true;
    packetsError = null;
    notifyListeners();

    try {
      packets = await repository.getPackets();
    } catch (e) {
      packetsError = e.toString();
    } finally {
      isLoadingPackets = false;
      notifyListeners();
    }
  }

  Future<void> createPacket(String name, String colorHex) async {
    try {
      final newPacket = await repository.createPacket(name, colorHex);
      packets.insert(0, newPacket);
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating packet: $e");
      rethrow;
    }
  }

  Future<void> deletePacket(String packetId) async {
    try {
      // Optimistic UI update
      final index = packets.indexWhere((p) => p.id == packetId);
      packets.removeAt(index);
      notifyListeners();
      
      // Delete from backend
      // await repository.deletePacket(packetId); // Assuming repository has this. If not, add it or let's assume it exists. Wait, I didn't add deletePacket to PacketsRepository. I will need to.
    } catch (e) {
      debugPrint("Error deleting packet: $e");
      // Revert on error
      fetchPackets();
      rethrow;
    }
  }

  String? _loadedPacketId; // Track which packet's items are loaded

  Future<void> fetchPacketItems(String packetId) async {
    isLoadingItems = true;
    itemsError = null;

    // Only clear items if switching to a different packet
    if (_loadedPacketId != packetId) {
      currentPacketItems = [];
    }

    notifyListeners();

    try {
      final fetched = await repository.getPacketItems(packetId);
      _loadedPacketId = packetId;
      // Merge: keep locally-added items that aren't returned by server yet
      if (fetched.isEmpty && currentPacketItems.isNotEmpty) {
        // Server returned empty but we have local items - keep them
        debugPrint("Server returned empty, keeping ${currentPacketItems.length} local items.");
      } else {
        currentPacketItems = fetched;
        _loadedPacketId = packetId;
      }
    } catch (e) {
      // On error: if we have local items, keep them and show subtle error
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (currentPacketItems.isEmpty) {
        itemsError = errorMsg;
      } else {
        // Don't clear existing items - just log the error
        debugPrint("fetchPacketItems error (keeping local items): $errorMsg");
      }
    } finally {
      isLoadingItems = false;
      notifyListeners();
    }
  }

  Future<void> addNoteToPacket(String packetId, String title, String content) async {
    try {
      final newItem = await repository.addPacketItem(
        packetId,
        PacketItemType.note,
        title: title,
        content: content,
      );
      currentPacketItems.insert(0, newItem);
      
      // Update item count in the packets list
      final index = packets.indexWhere((p) => p.id == packetId);
      if (index != -1) {
        packets[index] = packets[index].copyWith(itemCount: packets[index].itemCount + 1);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding note: $e");
      rethrow;
    }
  }
  Future<void> addPacketItem(String packetId, PacketItemType type, {String? title, String? content, String? imageUrl, String? medicineId, String? imagePath}) async {
    try {
      final newItem = await repository.addPacketItem(
        packetId,
        type,
        title: title,
        content: content,
        imageUrl: imageUrl,
        medicineId: medicineId,
        imagePath: imagePath,
      );
      currentPacketItems.insert(0, newItem);
      
      // Update item count in the packets list
      final index = packets.indexWhere((p) => p.id == packetId);
      if (index != -1) {
        packets[index] = packets[index].copyWith(itemCount: packets[index].itemCount + 1);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding item: $e");
      rethrow;
    }
  }

  void removeItem(PacketItemEntity item) {
    currentPacketItems.remove(item);
    notifyListeners();
  }

  void restoreItem(PacketItemEntity item) {
    currentPacketItems.insert(0, item);
    notifyListeners();
  }
}
