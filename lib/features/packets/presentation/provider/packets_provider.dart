import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';
import 'package:medinear_app/features/packets/domain/repositories/packets_repository.dart';
import 'package:medinear_app/features/packets/data/models/packet_model.dart';
import 'package:medinear_app/features/packets/data/models/packet_item_model.dart';

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
      final fetchedPackets = await repository.getPackets();
      if (fetchedPackets.isNotEmpty) {
        packets = fetchedPackets;
        await _savePacketsToLocal(fetchedPackets);
      } else {
        final localPackets = await _getStoredPackets();
        packets = localPackets;
      }
    } catch (e) {
      final localPackets = await _getStoredPackets();
      if (localPackets.isNotEmpty) {
        packets = localPackets;
      } else {
        packetsError = e.toString();
      }
    } finally {
      isLoadingPackets = false;
      notifyListeners();
    }
  }

  Future<void> createPacket(String name, String colorHex) async {
    try {
      final newPacket = await repository.createPacket(name, colorHex);
      packets.insert(0, newPacket);
      await _savePacketsToLocal(packets);
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
      if (index != -1) {
        packets.removeAt(index);
        await _savePacketsToLocal(packets);
        notifyListeners();
      }
      
      // Delete from backend (Not fully implemented in repository yet, but keeping structure)
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
      if (fetched.isNotEmpty) {
        currentPacketItems = fetched;
        await _saveItemsToLocal(packetId, fetched);
      } else {
        // Fallback to local cache if server returns empty
        final localItems = await _getStoredItems(packetId);
        if (localItems.isNotEmpty) {
          currentPacketItems = localItems;
        } else {
          currentPacketItems = [];
        }
      }
      _loadedPacketId = packetId;
    } catch (e) {
      final localItems = await _getStoredItems(packetId);
      if (localItems.isNotEmpty) {
        currentPacketItems = localItems;
        _loadedPacketId = packetId;
      } else {
        itemsError = e.toString().replaceAll('Exception: ', '');
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
      await _saveItemsToLocal(packetId, currentPacketItems);
      
      // Update item count in the packets list
      final index = packets.indexWhere((p) => p.id == packetId);
      if (index != -1) {
        packets[index] = packets[index].copyWith(itemCount: packets[index].itemCount + 1);
        await _savePacketsToLocal(packets);
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
      await _saveItemsToLocal(packetId, currentPacketItems);
      
      // Update item count in the packets list
      final index = packets.indexWhere((p) => p.id == packetId);
      if (index != -1) {
        packets[index] = packets[index].copyWith(itemCount: packets[index].itemCount + 1);
        await _savePacketsToLocal(packets);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding item: $e");
      rethrow;
    }
  }

  Future<void> removeItem(PacketItemEntity item) async {
    String pId = item.packetId.isEmpty ? (_loadedPacketId ?? "") : item.packetId;
    
    currentPacketItems.remove(item);
    await _saveItemsToLocal(pId, currentPacketItems);
    
    // Update item count in the packets list
    final index = packets.indexWhere((p) => p.id == pId);
    if (index != -1) {
      packets[index] = packets[index].copyWith(itemCount: (packets[index].itemCount - 1).clamp(0, 9999));
      await _savePacketsToLocal(packets);
    }
    notifyListeners();

    try {
      await repository.deletePacketItem(pId, item.id);
    } catch (e) {
      debugPrint("Error deleting item from server: $e");
      rethrow;
    }
  }

  Future<void> restoreItem(PacketItemEntity item) async {
    currentPacketItems.insert(0, item);
    await _saveItemsToLocal(item.packetId, currentPacketItems);
    
    // Update item count in the packets list
    final index = packets.indexWhere((p) => p.id == item.packetId);
    if (index != -1) {
      packets[index] = packets[index].copyWith(itemCount: packets[index].itemCount + 1);
      await _savePacketsToLocal(packets);
    }
    notifyListeners();
  }

  // --- Local Caching Helpers ---
  Future<void> _savePacketsToLocal(List<PacketEntity> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = items.map((e) {
      if (e is PacketModel) return e.toJson();
      return PacketModel(id: e.id, name: e.name, colorHex: e.colorHex, itemCount: e.itemCount, createdAt: e.createdAt).toJson();
    }).toList();
    await prefs.setString('packets_cache', jsonEncode(jsonList));
  }

  Future<List<PacketEntity>> _getStoredPackets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('packets_cache');
    if (data != null) {
      final List decoded = jsonDecode(data);
      return decoded.map<PacketEntity>((e) => PacketModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveItemsToLocal(String packetId, List<PacketItemEntity> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = items.map((e) {
      if (e is PacketItemModel) return e.toJson();
      return PacketItemModel(id: e.id, packetId: e.packetId, type: e.type, title: e.title, content: e.content, imageUrl: e.imageUrl, medicineId: e.medicineId, createdAt: e.createdAt).toJson();
    }).toList();
    await prefs.setString('packet_items_$packetId', jsonEncode(jsonList));
  }

  Future<List<PacketItemEntity>> _getStoredItems(String packetId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('packet_items_$packetId');
    if (data != null) {
      final List decoded = jsonDecode(data);
      return decoded.map<PacketItemEntity>((e) => PacketItemModel.fromJson(e)).toList();
    }
    return [];
  }
}
