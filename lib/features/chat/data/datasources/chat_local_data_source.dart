// هذا الملف مسؤول عن التخزين المؤقت للرسائل للعمل في وضع عدم الاتصال (Offline Mode)
abstract class ChatLocalDataSource {
  Future<void> cacheMessages(List<dynamic> messages);
  Future<List<dynamic>> getCachedMessages();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  @override
  Future<void> cacheMessages(List<dynamic> messages) async {
    // حفظ الرسائل في قاعدة البيانات المحلية
  }

  @override
  Future<List<dynamic>> getCachedMessages() async {
    // استرجاع الرسائل المحفوظة
    return [];
  }
}