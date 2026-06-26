import 'dart:io';
import 'package:dio/dio.dart';

abstract class ChatRemoteDataSource {
  Future<List<dynamic>> fetchChatHistory();
  Future<dynamic> startSession(int pharmacyId);
  Future<List<dynamic>> fetchMessages(int sessionId);
  Future<dynamic> sendMessage(int sessionId, String message, {File? imageFile, File? audioFile, File? documentFile});
  Future<void> readSession(int sessionId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> fetchChatHistory() async {
    final response = await dio.get('/chat/sessions');
    return response.data['sessions'] ?? [];
  }

  @override
  Future<dynamic> startSession(int pharmacyId) async {
    final response = await dio.post('/chat/sessions', data: {'pharmacy_id': pharmacyId});
    return response.data['session'];
  }

  @override
  Future<List<dynamic>> fetchMessages(int sessionId) async {
    final response = await dio.get('/chat/$sessionId/messages');
    return response.data['messages'] ?? [];
  }

  @override
  Future<dynamic> sendMessage(int sessionId, String message, {File? imageFile, File? audioFile, File? documentFile}) async {
    dynamic data;
    
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      data = FormData.fromMap({
        'message': message.isEmpty ? 'صورة' : message,
        'body': message.isEmpty ? 'صورة' : message,
        'type': 'image',
        'file_path': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });
    } else if (audioFile != null) {
      String fileName = audioFile.path.split('/').last;
      data = FormData.fromMap({
        'message': message.isEmpty ? 'مقطع صوتي' : message,
        'body': message.isEmpty ? 'مقطع صوتي' : message,
        'type': 'audio',
        'file_path': await MultipartFile.fromFile(audioFile.path, filename: fileName),
        'file': await MultipartFile.fromFile(audioFile.path, filename: fileName),
        'audio': await MultipartFile.fromFile(audioFile.path, filename: fileName),
      });
    } else if (documentFile != null) {
      String fileName = documentFile.path.split('/').last;
      data = FormData.fromMap({
        'message': message.isEmpty ? 'مستند' : message,
        'body': message.isEmpty ? 'مستند' : message,
        'type': 'file',
        'file_path': await MultipartFile.fromFile(documentFile.path, filename: fileName),
        'file': await MultipartFile.fromFile(documentFile.path, filename: fileName),
      });
    } else {
      data = {
        'message': message,
        'body': message,
        'type': 'text',
      };
    }

    final response = await dio.post('/chat/$sessionId/messages', data: data);
    return response.data['message'];
  }


  @override
  Future<void> readSession(int sessionId) async {
    await dio.post('/chat/$sessionId/read');
  }
}

