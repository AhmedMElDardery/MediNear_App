import '../datasources/wallet_local_data_source.dart';
import '../datasources/wallet_remote_data_source.dart';

// تعريف العقد (Contract) الخاص بمستودع البيانات
abstract class WalletRepository {
  Future<List<dynamic>> getWalletTransactions();
}

// التنفيذ الفعلي لمستودع البيانات (Implementation)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final WalletLocalDataSource localDataSource;

  // حقن الاعتماديات (Dependency Injection) لمصادر البيانات
  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<dynamic>> getWalletTransactions() async {
    try {
      // 1. محاولة جلب البيانات المحدثة من الخادم
      final remoteData = await remoteDataSource.fetchWalletData();

      // 2. تحديث التخزين المحلي بالبيانات الجديدة
      await localDataSource.cacheWalletData(remoteData);

      return remoteData;
    } catch (e) {
      // 3. التعامل مع الأخطاء (مثل انقطاع الاتصال) والرجوع للبيانات المحلية إن وجدت
      throw Exception('Failed to load data from server: $e');
    }
  }
}
