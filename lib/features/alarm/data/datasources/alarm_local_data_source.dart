// هذا الملف الأساسي للمنبه، مسؤول عن حفظ واسترجاع مواعيد التنبيهات من الجهاز
abstract class AlarmLocalDataSource {
  Future<List<dynamic>> getSavedAlarms();
  Future<void> saveAlarm(dynamic alarmData);
  Future<void> deleteAlarm(String id);
}

class AlarmLocalDataSourceImpl implements AlarmLocalDataSource {
  @override
  Future<List<dynamic>> getSavedAlarms() async {
    // استرجاع البيانات المخزنة محلياً من الجهاز
    return [];
  }

  @override
  Future<void> saveAlarm(dynamic alarmData) async {
    // حفظ تنبيه جديد
  }

  @override
  Future<void> deleteAlarm(String id) async {
    // حذف تنبيه موجود
  }
}
