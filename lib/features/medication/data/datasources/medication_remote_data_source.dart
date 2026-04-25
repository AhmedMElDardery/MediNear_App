// مسؤول عن جلب بيانات الأدوية من واجهة برمجة تطبيقات طبية أو مزامنة الوصفات
abstract class MedicationRemoteDataSource {
  Future<List<dynamic>> fetchPrescriptions();
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  @override
  Future<List<dynamic>> fetchPrescriptions() async {
    // محاكاة جلب قائمة الأدوية الخاصة بالمستخدم
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
