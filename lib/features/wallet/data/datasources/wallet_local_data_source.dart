// هذا الملف مسؤول عن التعامل مع قاعدة البيانات المحلية (التخزين المؤقت/الكاش)
abstract class WalletLocalDataSource {
  Future<void> cacheWalletData(dynamic data);
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  @override
  Future<void> cacheWalletData(dynamic data) async {
    // تنفيذ حفظ البيانات محلياً باستخدام حزم مثل Hive أو SharedPreferences
  }
}