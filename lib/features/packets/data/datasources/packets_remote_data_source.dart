import 'package:dio/dio.dart';
import 'package:medinear_app/features/packets/data/models/packet_model.dart';
import 'package:medinear_app/features/packets/data/models/packet_item_model.dart';

abstract class PacketsRemoteDataSource {
  Future<List<PacketModel>> getPackets();
  Future<PacketModel> createPacket(String title, String description);
  Future<void> deletePacket(String id);
  Future<List<PacketItemModel>> getPacketItems(String packetId);
  Future<PacketItemModel> addPacketItem(
    String packetId, 
    String type, 
    {String? title, String? content, String? imageUrl, String? medicineId, String? imagePath}
  );
  Future<void> deletePacketItem(String packetId, String itemId);
}

class PacketsRemoteDataSourceImpl implements PacketsRemoteDataSource {
  final Dio dio;

  PacketsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PacketModel>> getPackets() async {
    final response = await dio.get('/pharmacy/packets');
    if (response.data['success'] == true) {
      final List data = response.data['data']['data'];
      return data.map((e) => PacketModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message']);
    }
  }

  @override
  Future<PacketModel> createPacket(String title, String description) async {
    final response = await dio.post(
      '/pharmacy/packets',
      data: {
        'title': title,
        'description': description,
      },
    );
    if (response.data['success'] == true) {
      return PacketModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message']);
    }
  }

  @override
  Future<void> deletePacket(String id) async {
    final response = await dio.delete('/pharmacy/packets/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['message']);
    }
  }

  @override
  Future<List<PacketItemModel>> getPacketItems(String packetId) async {
    try {
      final response = await dio.get('/pharmacy/packets/$packetId/items');
      if (response.data['success'] == true) {
        var rawData = response.data['data'];
        List listData = [];
        if (rawData is List) {
          listData = rawData;
        } else if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
          listData = rawData['data'];
        }
        return listData.map((e) => PacketItemModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? e.response?.data.toString());
      }
      throw Exception(e.message);
    }
  }

  @override
  Future<PacketItemModel> addPacketItem(
    String packetId, 
    String type, 
    {String? title, String? content, String? imageUrl, String? medicineId, String? imagePath}
  ) async {
    try {
      String backendType = type == 'prescription' ? 'image' : type;

      final Map<String, dynamic> requestData = {
        'type': backendType,
      };

      if (backendType == 'note') {
        requestData['note'] = title != null ? "$title\n$content" : content;
      } else if (backendType == 'image') {
        // Upload as actual file using FormData
        if (imagePath != null) {
          final formData = FormData.fromMap({
            'type': backendType,
            'image': await MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split('/').last,
            ),
          });
          final response = await dio.post(
            '/pharmacy/packets/$packetId/items',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
          if (response.data['success'] == true) {
            return PacketItemModel.fromJson(response.data['data']);
          } else {
            throw Exception(response.data['message']);
          }
        } else {
          throw Exception('Please select an image file.');
        }
      } else if (backendType == 'medicine') {
        requestData['medicine_id'] = medicineId;
      }

      final response = await dio.post(
        '/pharmacy/packets/$packetId/items',
        data: requestData,
      );
      if (response.data['success'] == true) {
        return PacketItemModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null && e.response?.data is Map) {
        final Map data = e.response?.data;
        if (data.containsKey('errors')) {
          throw Exception(data['errors'].toString());
        }
        throw Exception(data['message'] ?? data.toString());
      }
      throw Exception(e.message);
    }
  }

  @override
  Future<void> deletePacketItem(String packetId, String itemId) async {
    try {
      final response = await dio.delete('/pharmacy/packets/$packetId/items/$itemId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? e.response?.data.toString());
      }
      throw Exception(e.message);
    }
  }
}
