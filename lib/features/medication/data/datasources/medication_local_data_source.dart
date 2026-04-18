// مسؤول عن تخزين قائمة الأدوية للوصول السريع بدون إنترنت
abstract class MedicationLocalDataSource {
  Future<void> cacheMedications(List<dynamic> medications);
  Future<List<dynamic>> getCachedMedications();
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  @override
  Future<void> cacheMedications(List<dynamic> medications) async {
    // حفظ قائمة الأدوية محلياً
  }

  @override
  Future<List<dynamic>> getCachedMedications() async {
    // استرجاع الأدوية المحفوظة
    return [];
  }
}