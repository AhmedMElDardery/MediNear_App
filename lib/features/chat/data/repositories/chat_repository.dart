import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';

// واجهة مستودع بيانات المحادثات
abstract class ChatRepository {
  Future<List<dynamic>> getMessages();
  Future<void> sendNewMessage(dynamic message);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<dynamic>> getMessages() async {
    try {
      final remoteMessages = await remoteDataSource.fetchChatHistory();
      await localDataSource.cacheMessages(remoteMessages);
      return remoteMessages;
    } catch (e) {
      return await localDataSource.getCachedMessages();
    }
  }

  @override
  Future<void> sendNewMessage(dynamic message) async {
    await remoteDataSource.sendMessage(message);
  }
}