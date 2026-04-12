// هذا الملف مسؤول عن إرسال واستقبال الرسائل من الخادم (Server)
abstract class ChatRemoteDataSource {
  Future<List<dynamic>> fetchChatHistory();
  Future<void> sendMessage(dynamic messageData);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<List<dynamic>> fetchChatHistory() async {
    // محاكاة لجلب سجل المحادثات من الـ API
    await Future.delayed(const Duration(milliseconds: 800));
    return [];
  }

  @override
  Future<void> sendMessage(dynamic messageData) async {
    // تنفيذ طلب POST لإرسال رسالة جديدة
  }
}