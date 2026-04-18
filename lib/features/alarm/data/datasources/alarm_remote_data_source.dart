// هذا الملف مسؤول عن مزامنة التنبيهات مع السحابة (Cloud Sync) في حال دعم الحسابات
abstract class AlarmRemoteDataSource {
  Future<void> syncAlarms(List<dynamic> alarms);
}

class AlarmRemoteDataSourceImpl implements AlarmRemoteDataSource {
  @override
  Future<void> syncAlarms(List<dynamic> alarms) async {
    // مزامنة البيانات مع الخادم للنسخ الاحتياطي
  }
}