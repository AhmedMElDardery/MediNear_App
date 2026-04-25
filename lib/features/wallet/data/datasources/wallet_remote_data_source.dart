// هذا الملف مسؤول عن التخاطب مع الخوادم الخارجية (APIs)
abstract class WalletRemoteDataSource {
  Future<List<dynamic>> fetchWalletData();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  @override
  Future<List<dynamic>> fetchWalletData() async {
    // محاكاة لطلب البيانات من الخادم عبر إطار عمل مثل Dio أو Http
    await Future.delayed(const Duration(seconds: 1));

    // إرجاع قائمة فارغة مؤقتاً لحين ربط الـ API الفعلي
    return [];
  }
}
