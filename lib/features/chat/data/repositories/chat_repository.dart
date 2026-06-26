import 'dart:io';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRepository {
  Future<List<ChatModel>> getSessions();
  Future<ChatModel> startSession(int pharmacyId);
  Future<List<MessageModel>> getCachedMessages(int sessionId);
  Future<List<MessageModel>> getMessages(int sessionId);
  Future<MessageModel> sendNewMessage(int sessionId, String message, {File? imageFile, File? audioFile, File? documentFile});
  Future<void> readSession(int sessionId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ChatModel>> getSessions() async {
    try {
      final remoteData = await remoteDataSource.fetchChatHistory();
      final sessions = remoteData.map((e) => ChatModel.fromJson(e)).toList();
      await localDataSource.cacheSessions(remoteData);
      return sessions;
    } catch (e) {
      final localData = await localDataSource.getCachedSessions();
      return localData.map((e) => ChatModel.fromJson(e)).toList();
    }
  }

  @override
  Future<ChatModel> startSession(int pharmacyId) async {
    final data = await remoteDataSource.startSession(pharmacyId);
    return ChatModel.fromJson(data);
  }

  @override
  Future<List<MessageModel>> getMessages(int sessionId) async {
    // This is called by ChatDetailsViewModel.
    // It should just fetch remote and cache it, because ChatDetailsViewModel will call getCachedMessages directly if needed,
    // OR we can just fetch and cache here. 
    final data = await remoteDataSource.fetchMessages(sessionId);
    await localDataSource.cacheChatMessages(sessionId, data);
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<List<MessageModel>> getCachedMessages(int sessionId) async {
    final localData = await localDataSource.getCachedChatMessages(sessionId);
    return localData.map((e) => MessageModel.fromJson(e)).toList();
  }

  @override
  Future<MessageModel> sendNewMessage(int sessionId, String message, {File? imageFile, File? audioFile, File? documentFile}) async {
    final data = await remoteDataSource.sendMessage(sessionId, message, imageFile: imageFile, audioFile: audioFile, documentFile: documentFile);
    return MessageModel.fromJson(data);
  }

  @override
  Future<void> readSession(int sessionId) async {
    await remoteDataSource.readSession(sessionId);
  }
}

