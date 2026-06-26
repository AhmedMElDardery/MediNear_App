import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// هذا الملف مسؤول عن التخزين المؤقت للرسائل للعمل في وضع عدم الاتصال (Offline Mode)
abstract class ChatLocalDataSource {
  Future<void> cacheSessions(List<dynamic> sessions);
  Future<List<dynamic>> getCachedSessions();
  Future<void> cacheChatMessages(int sessionId, List<dynamic> messages);
  Future<List<dynamic>> getCachedChatMessages(int sessionId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  @override
  Future<void> cacheSessions(List<dynamic> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_sessions', jsonEncode(sessions));
  }

  @override
  Future<List<dynamic>> getCachedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cached_sessions');
    if (data != null) {
      return jsonDecode(data);
    }
    return [];
  }

  @override
  Future<void> cacheChatMessages(int sessionId, List<dynamic> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_messages_$sessionId', jsonEncode(messages));
  }

  @override
  Future<List<dynamic>> getCachedChatMessages(int sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cached_messages_$sessionId');
    if (data != null) {
      return jsonDecode(data);
    }
    return [];
  }
}
